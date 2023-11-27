// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/gates.circom";
include "../../dep/extract.circom";

/** 
 * This template extracts the name from the body and checks that it's formatted correctly
 */
template NameRegex(msgBytes, maxName) {
    // msgBytes = nameRange + minName
    signal input in[msgBytes];

    signal input start;
    signal input len;

    assert(msgBytes < 65536); // because we use LessThan(16) gates to compare indices

    component isZero[msgBytes];
    component lt[6][msgBytes];

    for (var i = 0; i < msgBytes; i++) {
        //check value is not /r or /n (10 or 13)
        isZero[i] = IsZero();
        isZero[i].in <== (in[i] - 10) * (in[i] - 13);

        // this is 1 when index >= len + start
        // the idea is that we should ignore the indices greater than len + start 
        // because we don't need to assert anything 
        // about these characters
        lt[0][i] = LessThan(16);
        lt[0][i].in[0] <== len + start - 1;
        lt[0][i].in[1] <== i;

        // this is 1 when index < start. Again, the
        // check below won't constrain the type of character for indices of in before 
        // start
        lt[1][i] = LessThan(16);
        lt[1][i].in[0] <== i;
        lt[1][i].in[1] <== start;
        
        // if they are both true this will fail
        // isZero[i].out is 1 if the character is /r or /n
        // (1 - lt[0][i].out - lt[1][i].out) is 1 if the character is in the range
        0 === isZero[i].out * (1 - lt[0][i].out - lt[1][i].out);
    }

    // extract characters between start and len + start
    signal masked[msgBytes];
    for (var i = 0; i < msgBytes; i++) {
        masked[i] <== in[i] * (1 - lt[0][i].out - lt[1][i].out);
    }

    // parse out the name using a double array. We extract maxName, the range of the start index is
    // msgBytes - maxName (i.e. any index in in[msgBytes] could be part of name).
    component nameExtract = UncertaintyExtraction(msgBytes - maxName, maxName, 0, msgBytes);
    nameExtract.indicatorLen <== start;
    for (var i = 0; i < msgBytes; i++) {
        nameExtract.in[i] <== masked[i];
    }
    
    signal output out[maxName];
    for (var i = 0; i < maxName; i++){
        out[i] <== nameExtract.out[i];
    }
}

