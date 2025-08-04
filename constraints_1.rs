use crate::{clause, Clause, Constraint, ConstraintIter, Var};

impl Constraint for Var {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        assert_ne!(*self, 0);
        Box::new(std::iter::once(clause!(*self)))
    }
}

impl Constraint for Clause {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        Box::new(std::iter::once(self.clone()))
    }
}

#[derive(Debug)]
pub struct Equal(pub Var, pub Var);

impl Constraint for Equal {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        Box::new(
            vec![clause!(-self.0, self.1), clause!(self.0, -self.1)].into_iter(),
        )
    }
}

#[derive(Debug)]
pub struct NotEqual(pub Var, pub Var);

impl Constraint for NotEqual {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        Box::new(
            vec![clause!(self.0, self.1), clause!(-self.0, -self.1)].into_iter(),
        )
    }
}

#[derive(Debug)]
pub struct AtMostOnePairwise(pub Vec<Var>);

impl Constraint for AtMostOnePairwise {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        let vars = &self.0;
        Box::new(
            vars
                .iter()
                .enumerate()
                .map(move |(i, v1)| vars.iter().skip(i + 1).map(move |v2| (v1, v2)))
                .flatten()
                .map(|(v1, v2)| clause!(-v1, -v2)),
        )
    }
}

#[derive(Debug)]
pub struct SequentialCounter(pub Vec<Var>, pub usize);

impl Constraint for SequentialCounter {
    fn clauses<'a>(&'a self, new_var: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {

        let mut vars = self.0.iter().enumerate();
        let k = self.1;
        let n = vars.len();

        let mut result = Vec::new();
        let mut prev_s: Vec<Var> = (0..k).map(|_| new_var()).collect();

        if let Some((_, v)) = vars.next() {
            result.push(clause!(-v, prev_s[0]));
        } else {
            return Box::new(std::iter::empty());
        }

        for s in prev_s.iter().skip(1) {
            result.push(clause!(-s));
        }

        for (i, v) in vars {
            if i + 1 == n {
                result.push(clause!(-v, -*prev_s.last().unwrap()));
                break;
            }

            let new_s: Vec<Var> = (0..k).map(|_| new_var()).collect();

            result.push(clause!(-v, new_s[0]));
            result.push(clause!(-prev_s[0], new_s[0]));

            for j in 1..k {
                result.push(clause!(-v, -prev_s[j - 1], new_s[j]));
                result.push(clause!(-prev_s[j], new_s[j]));
            }

            result.push(clause!(-v, -*prev_s.last().unwrap()));
            prev_s = new_s;
        }

        Box::new(result.into_iter())
    }
}

#[derive(Debug, Clone)]
pub struct LogVar(pub Vec<Var>);

impl Constraint for LogVar {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        Box::new(self.0.iter().map(|v| clause!(*v)))
    }
}

#[derive(Debug)]
pub struct NotLogVar(pub LogVar);

impl Constraint for NotLogVar {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        Box::new((self.0).0.iter().map(|v| clause!(-*v)))
    }
}

#[derive(Debug)]
pub struct LogNotEqual(pub LogVar, pub LogVar);

impl Constraint for LogNotEqual {
    fn clauses<'a>(&'a self, _: &mut dyn FnMut() -> Var) -> ConstraintIter<'a> {
        let left = &(self.0).0;
        let right = &(self.1).0;

        assert_eq!(left.len(), right.len());

        let left = left.into_iter();
        let right = right.into_iter();
        let mut iter = left.zip(right);

        let mut clauses = Vec::new();
        if let Some((&a, &b)) = iter.next() {
            clauses.push(vec![a, b]);
            clauses.push(vec![-a, -b]);
        } else {
            return Box::new(std::iter::empty());
        }

        for (&a, &b) in iter {
            let clauses_len = clauses.len();
            for i in 0..clauses_len {
                let c = &mut clauses[i];
                let mut new = c.clone();
                new.push(a);
                new.push(b);
                c.push(-a);
                c.push(-b);
                clauses.push(new);
            }
        }

        Box::new(clauses.into_iter().map(|c| c.into_boxed_slice()))
    }
}

#[derive(Debug)]
pub struct LogEqual(pub LogVar, pub LogVar);

impl Constraint for LogEqual {
    fn clauses<'a>(
        &'a self,
        new_var: &mut dyn FnMut() -> Var,
    ) -> ConstraintIter<'a> {
        let left = &(self.0).0;
        let right = &(self.1).0;

        assert_eq!(left.len(), right.len());

        let mut clauses = Vec::new();
        for (&a, &b) in left.into_iter().zip(right.into_iter()) {
            clauses.extend(Equal(a, b).clauses(new_var));
        }

        Box::new(clauses.into_iter())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::SATEncoder;
    use std::collections::HashSet;

    #[test]
    fn at_most_one_pairwise_test() {
        let mut encoder = SATEncoder::<u32>::default();
        let v1 = encoder.var_map.new_var();
        let v2 = encoder.var_map.new_var();
        let v3 = encoder.var_map.new_var();
        encoder.add_constraint(AtMostOnePairwise(vec![v1, v2, v3]));
        drop(encoder.clauses());

        let mut expected = HashSet::new();
        expected.insert(clause!(-v1, -v2));
        expected.insert(clause!(-v2, -v3));
        expected.insert(clause!(-v1, -v3));
        assert_eq!(expected, encoder.clauses);
    }

    #[test]
    fn sequential_counter_test() {
        let mut encoder = SATEncoder::<u32>::default();
        let v1 = encoder.var_map.new_var();
        let v2 = encoder.var_map.new_var();
        let v3 = encoder.var_map.new_var();
        assert_eq!((v1, v2, v3), (1, 2, 3));
        encoder.add_constraint(SequentialCounter(vec![v1, v2, v3], 2));
        drop(encoder.clauses());

        let mut expected = HashSet::new();
        expected.insert(clause!(-1, 4));
        expected.insert(clause!(-5));
        expected.insert(clause!(-4, 6));
        expected.insert(clause!(-2, 6));
        expected.insert(clause!(-2, -4, 7));
        expected.insert(clause!(-5, 7));
        expected.insert(clause!(-2, -5));
        expected.insert(clause!(-3, -7));
        assert_eq!(expected, encoder.clauses);
    }

    #[test]
    fn sequential_counter_atmost_one_test() {
        let mut encoder = SATEncoder::<u32>::default();
        let v1 = encoder.var_map.new_var();
        let v2 = encoder.var_map.new_var();
        let v3 = encoder.var_map.new_var();
        assert_eq!((v1, v2, v3), (1, 2, 3));
        encoder.add_constraint(SequentialCounter(vec![v1, v2, v3], 1));
        drop(encoder.clauses());

        let mut expected = HashSet::new();
        expected.insert(clause!(-1, 4));
        expected.insert(clause!(-2, 5));
        expected.insert(clause!(-4, 5));
        expected.insert(clause!(-2, -4));
        expected.insert(clause!(-3, -5));
        assert_eq!(expected, encoder.clauses);
    }

    #[test]
    fn log_not_equal_test() {
        let mut encoder = SATEncoder::<u32>::default();
        let a0 = encoder.var_map.new_var();
        let b0 = encoder.var_map.new_var();
        let a1 = encoder.var_map.new_var();
        let b1 = encoder.var_map.new_var();
        encoder
            .add_constraint(LogNotEqual(LogVar(vec![a0, a1]), LogVar(vec![b0, b1])));
        drop(encoder.clauses());
        let mut expected = HashSet::new();
        expected.insert(clause!(a0, b0, a1, b1));
        expected.insert(clause!(-a0, -b0, a1, b1));
        expected.insert(clause!(a0, b0, -a1, -b1));
        expected.insert(clause!(-a0, -b0, -a1, -b1));
        assert_eq!(expected, encoder.clauses);
    }
}
