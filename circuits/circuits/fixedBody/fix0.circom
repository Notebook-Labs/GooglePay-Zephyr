// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix0Regex() {
    signal input in[18];
    var fixed[18] = [89, 111, 117, 32, 115, 101, 110, 116, 32, 109, 111, 110, 101, 121, 32, 116, 111, 32];
    // check input matches fixed
    for (var i = 0; i < 18; i++) {
        in[i] === fixed[i];
    }
}
    