// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/gates.circom";

/** 
 * This template verifies a fixed section of html.
 * More information can be found in the documentation
 */
template Fix4Regex() {
    signal input in[219];
    var fixed[219] = [13, 10, 13, 10, 0, 46, 0, 0, 0, 0, 45, 0, 0, 0, 0, 45, 0, 0, 0, 0, 45, 0, 0, 0, 0, 13, 10, 13, 10, 85, 115, 101, 32, 116, 104, 105, 115, 32, 110, 117, 109, 98, 101, 114, 32, 97, 115, 32, 97, 32, 114, 101, 102, 101, 114, 101, 110, 99, 101, 32, 105, 102, 32, 121, 111, 117, 32, 104, 97, 118, 101, 32, 105, 110, 113, 117, 105, 114, 105, 101, 115, 32, 97, 98, 111, 117, 116, 32, 116, 104, 105, 115, 32, 116, 114, 97, 110, 115, 97, 99, 116, 105, 111, 110, 13, 10, 13, 10, 13, 10, 71, 111, 111, 103, 108, 101, 32, 80, 97, 121, 109, 101, 110, 116, 32, 67, 111, 114, 112, 46, 44, 32, 49, 54, 48, 48, 32, 65, 109, 112, 104, 105, 116, 104, 101, 97, 116, 114, 101, 32, 80, 97, 114, 107, 119, 97, 121, 44, 32, 77, 111, 117, 110, 116, 97, 105, 110, 32, 86, 105, 101, 119, 44, 32, 67, 65, 32, 57, 52, 48, 52, 51, 44, 32, 32, 13, 10, 85, 83, 65, 13, 10, 13, 10, 84, 104, 105, 115, 32, 101, 109, 97, 105, 108, 32, 99, 111, 110, 102, 105, 114, 109, 115, 32, 116, 104, 97, 116, 32];
    // check input matches fixed
    for (var i = 0; i < 219; i++) {
        (in[i] - fixed[i]) * fixed[i] === 0;
    }

    

    
    //
    // Check and extract the identifier
    //

    // check the identifier values are 0-9 A-Z
    var identifierIndices[17] = [4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19, 21, 22, 23, 24];
    component lt[4][17];
    component and[2][17];
    signal numberSum[17];
    signal letterSum[17];
    for (var i = 0; i < 17; i++) {
        
        // check number
        lt[0][i] = LessThan(8);
        lt[0][i].in[0] <== 47;
        lt[0][i].in[1] <==  in[identifierIndices[i]];

        lt[1][i] = LessThan(8);
        lt[1][i].in[0] <==  in[identifierIndices[i]];
        lt[1][i].in[1] <== 58;

        and[0][i] = AND();
        and[0][i].a <== lt[0][i].out;
        and[0][i].b <== lt[1][i].out;

        numberSum[i] <== and[0][i].out * (in[identifierIndices[i]] - 48);

        // check letter
        lt[2][i] = LessThan(8);
        lt[2][i].in[0] <== 64;
        lt[2][i].in[1] <==  in[identifierIndices[i]];

        lt[3][i] = LessThan(8);
        lt[3][i].in[0] <==  in[identifierIndices[i]];
        lt[3][i].in[1] <== 91;

        and[1][i] = AND();
        and[1][i].a <== lt[2][i].out;
        and[1][i].b <== lt[3][i].out;

        letterSum[i] <== and[1][i].out * (in[identifierIndices[i]] - 55);

        and[0][i].out + and[1][i].out === 1;
    }

    // output nonce as a single signal
    signal nonce[17+1];
    nonce[0] <== 0;
     for (var i = 1; i <= 17; i++) {
        nonce[i] <== 36 * nonce[i - 1] + numberSum[i - 1] + letterSum[i - 1];
    }

    signal output out;
    out <== nonce[17];
    

}
    