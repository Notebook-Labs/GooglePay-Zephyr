// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix1Regex() {
    signal input in[5];
    var fixed[5] = [13, 10, 13, 10, 36];
    // check input matches fixed
    for (var i = 0; i < 5; i++) {
        in[i] === fixed[i];
    }
}
    