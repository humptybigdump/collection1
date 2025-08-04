pub mod dimacs {
    use crate::Clause;
    use std::io::Write;

    pub struct DIMACSBackend<W> {
        stream: W,
    }

    impl<W: Write> DIMACSBackend<W> {
        pub fn new(stream: W) -> Self {
            Self { stream }
        }

        pub fn add_clauses<'a>(
            &mut self,
            clauses: impl Iterator<Item = Clause> + 'a,
        ) -> Result<(), std::io::Error> {
            let clauses = clauses.collect::<Vec<_>>();

            let max_var = clauses
                .iter()
                .flat_map(|c| c.iter())
                .map(|v| v.abs())
                .max()
                .unwrap();
            let clause_count = clauses.len();

            println!("p cnf {} {}", max_var, clause_count);

            let mut buf = String::new();
            for c in clauses {
                buf.clear();
                for v in c.iter() {
                    buf.push_str(&format!("{} ", v));
                }
                buf.push_str("0\n");
                self.stream.write_all(buf.as_bytes())?;
            }
            Ok(())
        }
    }
}

pub mod dimspec {
    use crate::Clause;
    use std::{collections::HashSet, io::Write};

    #[derive(Debug, PartialEq, Eq, Clone, Copy)]
    #[repr(u8)]
    pub enum ClauseType {
        Initial = 0,
        Universal = 1,
        Goal = 2,
        Transition = 3,
    }

    #[derive(Debug, Default)]
    pub struct DIMSPECBackend {
        clauses: [Vec<Clause>; 4],
    }

    impl DIMSPECBackend {
        pub fn add_clauses(
            &mut self,
            ty: ClauseType,
            clauses: impl Iterator<Item = Clause>,
        ) {
            self.clauses[ty as usize].extend(clauses);
        }

        pub fn print_result<W: Write>(
            &self,
            stream: &mut W,
        ) -> Result<(), std::io::Error> {
            let vars =
                count_vars(self.clauses[..3].iter().map(|cl| cl.iter()).flatten());

            let clauses = &self.clauses[ClauseType::Initial as usize];
            stream.write_all(
                format!("i cnf {} {}\n", vars, clauses.len()).as_bytes(),
            )?;
            for clause in clauses.iter() {
                for v in clause.iter() {
                    stream.write_all(format!("{} ", v).as_bytes())?;
                }
                stream.write_all("0\n".as_bytes())?;
            }

            let clauses = &self.clauses[ClauseType::Universal as usize];
            stream.write_all(
                format!("u cnf {} {}\n", vars, clauses.len()).as_bytes(),
            )?;
            for clause in clauses.iter() {
                for v in clause.iter() {
                    stream.write_all(format!("{} ", v).as_bytes())?;
                }
                stream.write_all("0\n".as_bytes())?;
            }

            let clauses = &self.clauses[ClauseType::Goal as usize];
            stream.write_all(
                format!("g cnf {} {}\n", vars, clauses.len()).as_bytes(),
            )?;
            for clause in clauses.iter() {
                for v in clause.iter() {
                    stream.write_all(format!("{} ", v).as_bytes())?;
                }
                stream.write_all("0\n".as_bytes())?;
            }

            let clauses = &self.clauses[ClauseType::Transition as usize];
            stream.write_all(
                format!("t cnf {} {}\n", 2 * vars, clauses.len()).as_bytes(),
            )?;
            for clause in clauses.iter() {
                for v in clause.iter() {
                    stream.write_all(format!("{} ", v).as_bytes())?;
                }
                stream.write_all("0\n".as_bytes())?;
            }

            Ok(())
        }
    }

    fn count_vars<'a>(clauses: impl Iterator<Item = &'a Clause>) -> usize {
        let mut set = HashSet::new();

        for clause in clauses {
            for v in clause.iter() {
                set.insert(v.abs() as usize);
            }
        }

        if set.len() == 0 {
            return 0;
        }

        let max = set.iter().max().unwrap();

        *max
    }
}

pub mod debug {
    use crate::{Clause, ReverseVarMap};
    use std::{borrow::Cow, fmt::Debug};

    pub fn add_clauses<'a, T: Debug>(
        rev_map: &ReverseVarMap<'a, T>,
        clauses: impl Iterator<Item = Clause>,
    ) {
        for clause in clauses {
            for v in clause.iter() {
                let v_str = if let Some(v) = rev_map.get(*v) {
                    Cow::Owned(format!("{:?}", v))
                } else if let Some(_v) =
                    rev_map.get(v.abs() - rev_map.0.len() as i32)
                {
                    Cow::Owned(format!("X"))
                } else {
                    Cow::Borrowed("X")
                };
                if *v < 0 {
                    print!("!{} ", v_str);
                } else {
                    print!("{} ", v_str);
                }
            }
            println!();
        }
    }
}
