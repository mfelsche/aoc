const INPUT: &str = include_str!("input.txt");

fn main() {
    let part1_result: u32 = INPUT
        .lines()
        .filter(|s| !s.is_empty())
        .map(get_max_for_bank)
        .sum();
    println!("PART 1: {part1_result}");
}

/// get the max pairing for the bank
fn get_max_for_bank(bank: &str) -> u32 {
    if let Some((first_digit_pos, first_digit)) = bank
        .bytes()
        .enumerate()
        .take(bank.len() - 1) // ignore last element
        // our own max-by-key, only updating on strictly bigger values
        .fold(None, |acc: Option<(usize, u8)>, (pos, value)| {
            if acc.is_none_or(|(_acc_pos, acc_value)| value > acc_value) {
                Some((pos, value))
            } else {
                acc
            }
        })
        && let Some(second_digit) = bank.bytes().skip(first_digit_pos + 1).max()
    {
        // we chain both
        (u32::from(first_digit - 48) * 10) + u32::from(second_digit - 48)
    } else {
        0
    }
}

#[cfg(test)]
mod tests {
    use crate::get_max_for_bank;

    const EXAMPLE_INPUT: &str = include_str!("example_input.txt");
    const EXAMPLE_RESULT: u32 = 357;

    #[test]
    fn part1_test() {
        assert_eq!(98, get_max_for_bank("987654321111111"));
        assert_eq!(89, get_max_for_bank("811111111111119"));
        assert_eq!(78, get_max_for_bank("234234234234278"));
        assert_eq!(92, get_max_for_bank("818181911112111"));
    }

    #[test]
    fn part1_test_2() {
        assert_eq!(98, get_max_for_bank("987654321111111"));
    }

    #[test]
    fn part1_full() {
        let result: u32 = EXAMPLE_INPUT
            .lines()
            .filter(|s| !s.is_empty())
            .map(get_max_for_bank)
            .sum();
        assert_eq!(EXAMPLE_RESULT, result);
    }
}
