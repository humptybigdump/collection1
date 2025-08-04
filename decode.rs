use crate::sudoku_parser::SudokuData;

pub fn decode(n: u32, data: Vec<i32>) -> SudokuData {
    let mut result = SudokuData {
        n,
        data: vec![0; (n * n * n * n * n * n) as usize],
    };

    assert_eq!(data.len() as u32, n * n * n * n * n * n);

    for r in data.iter().filter(|r| **r >= 0) {
        let (x, y, n) = result.reverse_var(*r);
        let field = &result.data[(y * result.n * result.n + x) as usize];
        assert_eq!(*field, 0, "{} {} {} \n{}", x, y, n, &result);

        let field = &mut result.data[(y * result.n * result.n + x) as usize];
        *field = n + 1;
    }

    for (_, _, n) in result.iter_fields() {
        assert_ne!(n, 0);
    }

    result
}
