# Templates Tests suite

This folder contains a test suite for asserting that the distribution templates are generating the expected output.

Inside this folder you will find a subfolder for each SIGHUP Distribution provider, and inside each subfolder you will find the tests cases for that provider.

The tests are executed as follows:

1. A `baseline` folder is created for each test case, containing the expected output.
2. The test case is executed, and the output is compared to the `baseline` folder.
3. If the output does not match the `baseline`, the test fails.

## Running the tests

To run the tests, execute the following command:

```
mise run test:templates:regression
```

## Updating the baseline

If changes to the templates are made, the `baseline` folder for all test cases should be updated to reflect the new output.

First run the regression tests to ensure the changes are not breaking other parts of the output:

```
mise run test:templates:regression
```

if the changes are the expected, update the `baseline` folder for all test cases:

```
mise run test:templates:update-baseline
```
