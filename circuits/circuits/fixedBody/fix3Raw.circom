// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix3RawRegex() {
    signal input in[87];
    var fixed[87] = [13, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 116, 101, 120, 116, 47, 104, 116, 109, 108, 59, 32, 99, 104, 97, 114, 115, 101, 116, 61, 34, 85, 84, 70, 45, 56, 34, 13, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 114, 97, 110, 115, 102, 101, 114, 45, 69, 110, 99, 111, 100, 105, 110, 103, 58, 32, 113, 117, 111, 116, 101, 100, 45, 112, 114, 105, 110, 116, 97, 98, 108, 101];
    // check input matches fixed
    for (var i = 0; i < 87; i++) {
        in[i] === fixed[i];
    }
}
    