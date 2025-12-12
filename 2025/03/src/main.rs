const INPUT: &str = include_str!("input.txt");

fn main() {
    let part1_result: u64 = INPUT
        .lines()
        .filter(|s| !s.is_empty())
        .map(get_max_for_bank_with_crawler::<2>)
        .sum();

    println!("PART 1: {part1_result}");
    let part2_result: u64 = INPUT
        .lines()
        .filter(|s| !s.is_empty())
        .map(get_max_for_bank_with_crawler::<12>)
        .sum();

    println!("PART 2: {part2_result}");
}

fn get_max_for_bank_with_crawler<const LEN: usize>(bank: &str) -> u64 {
    let bytes = bank.as_bytes();
    let len = bytes.len();
    if len < LEN {
        0
    } else {
        let mut joltages = [0_u8; LEN];
        joltages[0] = bytes[0];

        let joltages =
            bytes
                .iter()
                .enumerate()
                .skip(1)
                .fold(joltages, |mut joltages, (pos, elem)| {
                    // go through all the joltages and check if:
                    let mut found_higher_joltage_at = LEN + 1;
                    for (jpos, joltage) in joltages.iter_mut().enumerate() {
                        if found_higher_joltage_at < LEN {
                            // if we did set the previous joltage to something bigger,
                            // set all further joltages to 0
                            *joltage = 0;
                            continue;
                        }

                        //  - current elem is a possible candidate for current joltage based on `pos`
                        //  - current elem > current joltage
                        if pos + (LEN - jpos) <= bytes.len() && *elem > *joltage {
                            *joltage = *elem;
                            found_higher_joltage_at = jpos;
                        }
                    }
                    joltages
                });
        joltages.iter().fold(0_u64, |acc, elem| {
            (acc * 10) + u64::from(elem.saturating_sub(b'0'))
        })
    }
}

#[cfg(test)]
mod tests {
    use crate::get_max_for_bank_with_crawler;

    const EXAMPLE_INPUT: &str = include_str!("example.txt");
    const EXAMPLE_RESULT: u64 = 357;

    #[test]
    fn get_max_for_bank_with_crawler_2_test() {
        assert_eq!(98, get_max_for_bank_with_crawler::<2>("987654321111111"));
        assert_eq!(89, get_max_for_bank_with_crawler::<2>("811111111111119"));
        assert_eq!(78, get_max_for_bank_with_crawler::<2>("234234234234278"));
        assert_eq!(92, get_max_for_bank_with_crawler::<2>("818181911112111"));
    }

    #[test]
    fn get_max_for_bank_with_crawler_12_test() {
        assert_eq!(
            987654321111,
            get_max_for_bank_with_crawler::<12>("987654321111111")
        );
        assert_eq!(
            811111111119,
            get_max_for_bank_with_crawler::<12>("811111111111119")
        );
        assert_eq!(
            434234234278,
            get_max_for_bank_with_crawler::<12>("234234234234278")
        );
        assert_eq!(
            888911112111,
            get_max_for_bank_with_crawler::<12>("818181911112111")
        );
    }

    #[test]
    fn part1_full_with_crawler() {
        let result: u64 = EXAMPLE_INPUT
            .lines()
            .filter(|s| !s.is_empty())
            .map(get_max_for_bank_with_crawler::<2>)
            .sum();
        assert_eq!(EXAMPLE_RESULT, result);
    }
}
