# now8 app

*now8 (no wait)* provides improved public transport arrival time estimations
using Machine Learning.

This is a Flutter app compatible with Android, IOS, web and more.

The web version is available at <https://now8.systems>.

## Download

You can download the latest version for Android devices from the
[releases page](https://github.com/now8-org/app/releases).

## Documentation

The documentation of this project is available at
<https://now8-org.github.io/app/>.

## Development

### Tools

* The `Makefile` contains most of the commands that you'll need. Start by
  running `make install`, which will install the required dependencies to get
  you started. Then, you can try with `make run`.
* Make sure that the [pre-commit](https://pre-commit.com/) checks pass before
  committing. If you ran `make install` they will be executed by default
  whenever you try to commit.
* We also use [Commitizen](https://commitizen-tools.github.io/commitizen/);
  instead of running `git commit` run `cz c`.

### Guideline

* Work in branches and open pull requests.
* Document your code.
* Add tests for your code.
