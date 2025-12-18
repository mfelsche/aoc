use std::ops::RangeInclusive;
const INPUT: &str = include_str!("../input.txt");

fn main() {
    let part1 = get_fresh_ingredients(INPUT);
    println!("PART 1: {part1}");
    let part2 = get_all_fresh_ingredients(INPUT);
    println!("PART 2: {part2}");
}

#[derive(Default, Debug)]
struct Ranges {
    ranges: Vec<RangeInclusive<u64>>,
}

impl Ranges {
    fn insert(&mut self, range: RangeInclusive<u64>) {
        for existing in &mut self.ranges {
            if existing.contains(range.start()) {
                // extend the range to back and front
                *existing =
                    *(existing.start().min(range.start()))..=*(range.end().max(existing.end()));
                return;
            }
        }
        let idx = self
            .ranges
            .partition_point(|r| r.end() < range.start() && r.start() < range.start());
        self.ranges.insert(idx, range);
    }

    fn merge(&mut self) {
        self.ranges = self.ranges.iter().fold(Vec::new(), |mut acc, range| {
            match acc.last_mut() {
                Some(last) => {
                    if last.contains(range.start()) {
                        // extend the last range to back and front
                        *last = (*last.start().min(range.start()))..=(*range.end().max(last.end()));
                    } else {
                        acc.push(range.clone());
                    }
                }
                None => {
                    acc.push(range.clone());
                }
            }
            acc
        });
    }
    fn contains(&self, ingredient: u64) -> bool {
        self.ranges.iter().any(|range| range.contains(&ingredient))
    }

    fn count(&self) -> u64 {
        self.ranges.iter().map(|r| r.end() - r.start() + 1).sum()
    }
}

fn parse_range(line: &str) -> Option<(u64, u64)> {
    let mut iter = line.trim().split('-');
    iter.next()
        .zip(iter.next())
        .and_then(|(lower_str, upper_str)| {
            lower_str
                .parse::<u64>()
                .ok()
                .zip(upper_str.parse::<u64>().ok())
        })
}

fn get_fresh_ingredients(input: &str) -> u64 {
    let mut ranges_done = false;
    let mut num_fresh: u64 = 0;
    let mut ranges = Ranges::default();
    for line in input.lines() {
        if line.is_empty() {
            // switch to list of ingredients
            ranges_done = true;
            //dbg!(&ranges);
            ranges.merge();
            //dbg!(&ranges);
            continue;
        }
        if ranges_done {
            // check list of ingredients against ranges
            if let Ok(ingredient) = line.trim().parse::<u64>()
                && ranges.contains(ingredient)
            {
                num_fresh += 1;
            }
        } else {
            // accumulate ranges
            if let Some((lower, upper)) = parse_range(line) {
                ranges.insert(lower..=upper);
            }
        }
    }
    num_fresh
}

fn get_all_fresh_ingredients(input: &str) -> u64 {
    let mut ranges = Ranges::default();
    let mut count = 0;
    for line in input.lines() {
        if line.is_empty() {
            //dbg!(&ranges);
            ranges.merge();
            //dbg!(&ranges);
            count = ranges.count();
            break;
        }
        // accumulate ranges
        if let Some((lower, upper)) = parse_range(line) {
            ranges.insert(lower..=upper);
            //dbg!(&ranges);
        }
    }
    count
}

#[cfg(test)]
mod tests {
    use crate::get_all_fresh_ingredients;

    use super::get_fresh_ingredients;
    const EXAMPLE: &str = "3-5
10-14
16-20
12-18

1
5
8
11
17
32";

    #[test]
    fn part1() {
        assert_eq!(3, get_fresh_ingredients(EXAMPLE));
    }

    #[test]
    fn part2() {
        assert_eq!(14, get_all_fresh_ingredients(EXAMPLE));
    }

    const EXAMPLE2: &str = "7-10
8-12
4-6
9-13
12-20

";

    #[test]
    fn part2_example2() {
        assert_eq!(17, get_all_fresh_ingredients(EXAMPLE2))
    }
}
