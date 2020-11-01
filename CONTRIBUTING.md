# Contributing
First off, thanks for taking the time to contribute! You can contribute to this project in many ways:

* Testing and reporting bugs
* Proposing new features
* Submitting a small fix
* Coding new features

Contact us and our community in the [dedicated discord server](https://discord.com/invite/ByeyTXS).

## The license of your contributions
When you submit anything to this project, your submissions are understood to be under the same license that covers the project. Please check [LICENSE](LICENSE) and
[README.md](README.md) files. Most of the contributions of this project are under the GNU GPLv3 license, and any contribution from you will be irrevocably considered
under this license. Feel free to contact the maintainers if that's a concern.

## Guidelines for developers
First of all, we appreciate you would like to contribute! Please make sure to get in touch with us before coding anything, the development is very active and
we don't want you to waste time coding something that is already under development.

### Git flow
This project use git and GitHub as the hosting platform. You should get familiar with git and the [github flow](https://guides.github.com/introduction/flow/index.html)
because your contributions will be included via a pull-request process. Meaningful git messages help the developers in understanding what you did. Each git
commit should be as small as possible and introduce one single feature, packing up several features in one large commit makes the integration of your code harder.

### Programming language
All the systems of the aircraft are currently coded in LUA and by using the SASL framework. Please understand we can't accept code in a different programming
language or using other plugins unless there is a very strong reason to do that. The switch to any other programming language or framework must be preliminarily discussed with the development team or your contributions won't be accepted, even if it is a small part of the project.

### Coding rules
Since we are at the beginning of the project, we decided to not enforce strict rules on coding. However, your code should be readable and documented when it's
not self-explanatory. As general rules, your code must be correctly indented, duplicated code should be avoided, and functions and files should remain small.
The use of spaces (4) instead of tabs for indentation is encouraged.

### Special files
* **DO NOT edit the .acf file without contacting the developers**. This is for two reasons: 
  * The .acf file is a critical file affecting many systems, we must be sure any edit doesn't negatively affect any part of the aircraft.
  * A conflicted .acf can take hours to manually merge it with a text editor, we don't really want to waste time in doing that.
* Be careful in editing `main.lua` and other global files like `constants.lua`, etc. We suggest you to coordinate any edit in such files with the developers.
* Global files used in many other files:
  * `constants.lua`: a set of useful constant. Don't put any logic here.
  * `dynamic_datarefs.lua`: the set of datarefs referring to the internal status of systems. Don't put any logic here.
  * `cockpit_datarefs.lua`: the set of datarefs referring to lights/buttons and visible objects. Don't put any logic here.
  * `cockpit_commands.lua`: the set of custom command referring to lights/buttons in the cockpit. Don't put any logic here.
  * `global_functions.lua`: a cluttered file containing many functions for miscellanea operation. 
    * _(Comment by RicoRico: this file starts to become a real mess, please try to avoid to put anything else here!)_
