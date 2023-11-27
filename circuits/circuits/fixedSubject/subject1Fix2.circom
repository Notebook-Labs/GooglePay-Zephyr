// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 * All equality testing so 0 constraints - all just labelling
 */
template Subject1Fix2Regex() {
    signal input in[2];
    var fixed[2] = [32, 36];
    // check input matches fixed
    for (var i = 0; i < 2; i++) {
        in[i] === fixed[i];
    }
}
    