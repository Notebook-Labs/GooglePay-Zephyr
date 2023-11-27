// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Subject0Fix1Regex() {
    signal input in[67];
    var fixed[67] = [13, 10, 102, 114, 111, 109, 58, 71, 111, 111, 103, 108, 101, 32, 80, 97, 121, 32, 60, 103, 111, 111, 103, 108, 101, 112, 97, 121, 45, 110, 111, 114, 101, 112, 108, 121, 64, 103, 111, 111, 103, 108, 101, 46, 99, 111, 109, 62, 13, 10, 115, 117, 98, 106, 101, 99, 116, 58, 89, 111, 117, 32, 115, 101, 110, 116, 32];
    // check input matches fixed
    for (var i = 0; i < 67; i++) {
        in[i] === fixed[i];
    }
}
    