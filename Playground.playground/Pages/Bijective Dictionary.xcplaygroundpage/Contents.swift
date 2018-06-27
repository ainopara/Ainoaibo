import Ainoaibo

let test: BijectiveDictionary<String, Int> = [
    "10": 100
]

test.add(key: "1", value: 1)
test.add(key: "2", value: 2)
test.add(key: "3", value: 3)

for (key, value) in test {
    print(key, value)
}

test.map { $0.0 }.forEach { print($0) }

test.add(key: "1", value: 5)

for (key, value) in test {
    print(key, value)
}

test.add(key: "1", value: 5)
test.add(key: "s", value: 5)
