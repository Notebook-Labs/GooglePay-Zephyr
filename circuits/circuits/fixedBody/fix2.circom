// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix2Regex() {
    signal input in[16];
    var fixed[16] = [13, 10, 13, 10, 119, 97, 115, 32, 115, 101, 110, 116, 32, 116, 111, 32];
    // check input matches fixed
    for (var i = 0; i < 16; i++) {
        in[i] === fixed[i];
    }
}
    