# Lab 6

## Starting Schema

The attributes for the relation are:

```
R = {ride} = {rider, driver, start, end, miles, car, payment, fare, card_number, vin}
```

The only key for the un-normalized relation is: ```{rider, driver, start, end}```

You are given the following functional dependencies:

```
- {rider} → {payment}
- {rider} → {card_number}
- {driver} → {vin}
- {vin} → {car}
- {start, end} → {miles, fare}
- {miles} → {fare}
```

## Step 1

1. Starting schema: R
2. Decompose on {rider} → {payment}

3. Results:
   - R1 = {rider, payment}, key = rider
   - R2 = {rider, driver, start, end, miles, car, fare, card_number, vin}, key = {rider, driver, start, end}

Step 2

1. Starting schema: R1, R2
2. Decompose on {rider} → {card_number}
3. Results:
    - R3 = {rider, card_number}, key = rider
    - R4 = {rider, driver, start, end, miles, car, fare, vin}, key = {rider, driver, start, end}

Step 3

1. Starting schema: R4
2. Decompose on {driver} → {vin}
3. Results:
   - R5 = {driver, vin}, key = driver
   - R6 = {rider, start, end, miles, fare, car}, key = {rider, start, end}

Step 4

1. Starting schema: R6
2. Decompose on {vin} → {car}
3. Results:
   - R7 = {vin, car}, key = vin
   - R8 = {rider, start, end, miles, fare, driver}, key = {rider, start, end}

Step 5

1. Starting schema: R8
2. Decompose on {start, end} → {miles, fare}
3. Results:
   - R9 = {start, end, miles, fare}, key = {start, end}
   - R10 = {rider, driver}, key = rider

Step 6

1. Starting schema: R9
2. Decompose on {miles} → {fare}
3. Results:
   - R11 = {miles, fare}, key = miles

Final database:

- R1 = {rider, payment}, key = rider
- R3 = {rider, card_number}, key = rider
- R5 = {driver, vin}, key = driver
- R7 = {vin, car}, key = vin
- R9 = {start, end, miles, fare}, key = {start, end}
- R10 = {rider, driver}, key = rider
- R11 = {miles, fare}, key = miles
