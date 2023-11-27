// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Subject0Fix0Regex() {
    signal input in[3];
    var fixed[3] = [116, 111, 58];
    // check input matches fixed
    for (var i = 0; i < 3; i++) {
        in[i] === fixed[i];
    }
}
    