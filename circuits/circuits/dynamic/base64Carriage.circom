// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/gates.circom";
include "../../dep/bigintFunc.circom";

/** 
 * Parses and decodes a base64 string into an ascii array. The idea is that in google pay emails,
 * the base64 string is split into lines of 78 characters, with carriage returns at the end of each line.
 */
template Base64Carriage(msgBytes) {
    signal input in[msgBytes];
    signal input len;

    signal output noCarriage[msgBytes];

    var lenCeil = logCeil(msgBytes);

    var carriageLength = ((msgBytes - msgBytes % 78)\78)*2;
    
    //carriage indices will be known at compile time
    var carriageIndices[carriageLength];
    for (var i = 0; i < msgBytes; i++) {
        if (i % 78 == 0 && i != 0) {
            carriageIndices[(i\78) * 2 - 2] = i - 2;
            carriageIndices[(i\78) * 2 - 1] = i - 1;
        }
    }
    
    //constrain all carriage indices to be either 10 or 13 when less than length
    component lt[carriageLength];
    signal isCarriage[carriageLength];
    for (var i = 0; i < carriageLength; i++) {
        lt[i] = LessThan(lenCeil);
        lt[i].in[0] <== carriageIndices[i];
        //FLAG: assuming you don't need a +1 but need to double check
        lt[i].in[1] <== len; //1 if less than length, 0 otherwise

        isCarriage[i] <== (in[carriageIndices[i]] - 10) * (in[carriageIndices[i]] - 13); //0 if carriage, non-zero otherwise
        0 === isCarriage[i] * lt[i].out;
    }

    //rotate carriage indices away
    
    //loop through all indices not in carriageIndices
    for (var i = 0; i < msgBytes; i++) {
        //map known at compile time
        if ((i + 2) % 78 != 0 && (i + 1) % 78 != 0) {
            var map = i - 2 * (i \ 78);
            noCarriage[map] <== in[i];
        }
    }

    for (var i = 0; i < carriageLength; i++) {
       noCarriage[msgBytes - 1 - i] <== 0;
    }

    signal offset <-- len \ 78; //unconstrained as not a quadratic constraint

    //constrain offset and check: len - 78 < 78 * offset <= len
    component remainderLb = LessThan(7);
    remainderLb.in[0] <== len - 78;
    remainderLb.in[1] <== 78 * offset;

    component remainderUb = LessThan(7);
    remainderUb.in[0] <== 78 * offset;
    remainderUb.in[1] <== len + 1;
    remainderUb.out * remainderLb.out === 1; //force both to be 1

    //length to extract after rotating away carriage returns
    signal output rotatedLen <== len - 2 * offset;
}


/** 
 * Parses and decodes a base64 string into an ascii array. The idea is that in google pay emails,
 * the base64 string is split into lines of 78 characters, with carriage returns at the end of each line.
 */
template Base64CarriageSubject(msgBytes) {
    signal input in[msgBytes];
    signal input len;

    signal output noCarriage[msgBytes];

    var lenCeil = logCeil(msgBytes);

    var carriageLength = ((msgBytes - msgBytes % 81)\81)*13;

    var transition[13] = [63, 61, 32, 61, 63, 85, 84, 70, 45, 56, 63, 66, 63];
    
    //carriage indices will be known at compile time
    var carriageIndices[carriageLength];
    for (var i = 0; i < msgBytes; i++) {
        if (i % 81 == 0 && i != 0) {
            carriageIndices[(i\81) * 13 - 13] = i - 13;
            carriageIndices[(i\81) * 13 - 12] = i - 12;
            carriageIndices[(i\81) * 13 - 11] = i - 11;
            carriageIndices[(i\81) * 13 - 10] = i - 10;
            carriageIndices[(i\81) * 13 - 9] = i - 9;
            carriageIndices[(i\81) * 13 - 8] = i - 8;
            carriageIndices[(i\81) * 13 - 7] = i - 7;
            carriageIndices[(i\81) * 13 - 6] = i - 6;
            carriageIndices[(i\81) * 13 - 5] = i - 5;
            carriageIndices[(i\81) * 13 - 4] = i - 4;
            carriageIndices[(i\81) * 13 - 3] = i - 3;
            carriageIndices[(i\81) * 13 - 2] = i - 2;
            carriageIndices[(i\81) * 13 - 1] = i - 1;
        }
    }
    
    //constrain all carriage indices to be either 10 or 13 when less than length
    component lt[carriageLength];
    for (var i = 0; i < carriageLength; i++) {
        lt[i] = LessThan(lenCeil);
        lt[i].in[0] <== carriageIndices[i];
        //FLAG: assuming you don't need a +1 but need to double check
        lt[i].in[1] <== len; //1 if less than length, 0 otherwise

        0 === (in[carriageIndices[i]] - transition[i % 13]) * lt[i].out;
    }

    //rotate carriage indices away
    
    //loop through all indices not in carriageIndices
    for (var i = 0; i < msgBytes; i++) {
        //map known at compile time
        if (i % 81 < 68) {
            var map = i - 13 * (i \ 81); 
            noCarriage[map] <== in[i];
        }
    }

    for (var i = 0; i < carriageLength; i++) {
       noCarriage[msgBytes - 1 - i] <== 0;
    }

    signal offset <-- len \ 81; //unconstrained as not a quadratic constraint

    //constrain offset and check: len - 78 < 78 * offset <= len
    component remainderLb = LessThan(7);
    remainderLb.in[0] <== len - 81;
    remainderLb.in[1] <== 81 * offset;

    component remainderUb = LessThan(7);
    remainderUb.in[0] <== 81 * offset;
    remainderUb.in[1] <== len + 1;
    remainderUb.out * remainderLb.out === 1; //force both to be 1

    //length to extract after rotating away carriage returns
    signal output rotatedLen <== len - 13 * offset;
}
