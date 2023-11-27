// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Fix1RawRegex() {
    signal input in[108];
    var fixed[108] = [13, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 116, 101, 120, 116, 47, 112, 108, 97, 105, 110, 59, 32, 99, 104, 97, 114, 115, 101, 116, 61, 34, 85, 84, 70, 45, 56, 34, 59, 32, 102, 111, 114, 109, 97, 116, 61, 102, 108, 111, 119, 101, 100, 59, 32, 100, 101, 108, 115, 112, 61, 121, 101, 115, 13, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 114, 97, 110, 115, 102, 101, 114, 45, 69, 110, 99, 111, 100, 105, 110, 103, 58, 32, 98, 97, 115, 101, 54, 52, 13, 10, 13, 10];
    // check input matches fixed
    for (var i = 0; i < 108; i++) {
        in[i] === fixed[i];
    }
}
    