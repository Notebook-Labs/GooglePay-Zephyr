// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Subject1Fix1Regex() {
    signal input in[24];
    var fixed[24] = [13, 10, 99, 99, 58, 13, 10, 115, 117, 98, 106, 101, 99, 116, 58, 89, 111, 117, 32, 115, 101, 110, 116, 32];
    // check input matches fixed
    for (var i = 0; i < 24; i++) {
        in[i] === fixed[i];
    }
}
    