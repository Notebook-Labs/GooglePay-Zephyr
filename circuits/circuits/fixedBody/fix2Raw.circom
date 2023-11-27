// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix2RawRegex() {
    signal input in[4];
    var fixed[4] = [13, 10, 45, 45];
    // check input matches fixed
    for (var i = 0; i < 4; i++) {
        in[i] === fixed[i];
    }
}
    