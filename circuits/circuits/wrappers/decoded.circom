// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../dep/extract.circom";
include "../dynamic/name.circom";
include "../dynamic/amount.circom";
include "../fixedBody/fix0.circom";
include "../fixedBody/fix1.circom";
include "../fixedBody/fix2.circom";
include "../fixedBody/fix3.circom";
include "../fixedBody/fix4.circom";

template Decoded(msgBytes) {

    signal input in[msgBytes];
    signal input nameLen;
    signal input amountLen;
    signal input messageLen;
    signal input paymentLen;

    var fix0Len = 18;
    var fix1Len = 5;
    var fix2Len = 16;
    var fix3Len = 191;
    var fix4Len = 219;
    var nameMin = 1;
    var nameMax = 300;
    var amountMin = 1;
    var amountMax = 8;
    var messageMin = 8;
    var messageMax = 4100;
    var paymentMin = 50;
    var paymentMax = 75;




    var nameRange = nameMax - nameMin + 1;
    var amountRange = nameRange + amountMax - amountMin;
    var messageRange = amountRange + messageMax - messageMin;
    var paymentRange = messageRange + paymentMax - paymentMin;


    component fix0Regex = Fix0Regex();
    for (var i = 0; i < fix0Len; i++) {
        fix0Regex.in[i] <== in[0 + i];
    }


    signal output name[nameMax];
    component nameRegex = NameRegex(nameRange + nameMin, nameMax);
    for (var i = 0; i < nameRange + nameMin; i++) {
        nameRegex.in[i] <== in[fix0Len + i];
    }
    nameRegex.start <== 0;
    nameRegex.len <== nameLen;
    for (var i = 0; i < nameMax; i++) {
        name[i] <== nameRegex.out[i];
     }


    component nameUncertainty = UncertaintyExtraction(nameRange, fix1Len, fix0Len + nameMin, msgBytes);
    nameUncertainty.indicatorLen <== nameLen - nameMin;
    for (var i = 0; i < msgBytes; i++) {
        nameUncertainty.in[i] <== in[i];
    }
    signal fix1Array[fix1Len];
    for (var i = 0; i < fix1Len; i++) {
        fix1Array[i] <== nameUncertainty.out[i];
    }


    component fix1Regex = Fix1Regex();
    for (var i = 0; i < fix1Len; i++) {
        fix1Regex.in[i] <== fix1Array[0 + i];
    }


    signal output amount;
    component amountRegex = AmountRegex(amountRange + amountMin);
    for (var i = 0; i < amountRange + amountMin; i++) {
        amountRegex.in[i] <== in[fix0Len + fix1Len + nameMin + i];
    }
    amountRegex.start <== nameLen - nameMin;
    amountRegex.len <== amountLen;
    amount <== amountRegex.out;


    component amountUncertainty = UncertaintyExtraction(amountRange, fix2Len, fix0Len + fix1Len + nameMin + amountMin, msgBytes);
    amountUncertainty.indicatorLen <== amountLen - amountMin + nameLen - nameMin;
    for (var i = 0; i < msgBytes; i++) {
        amountUncertainty.in[i] <== in[i];
    }
    signal fix2Array[fix2Len];
    for (var i = 0; i < fix2Len; i++) {
        fix2Array[i] <== amountUncertainty.out[i];
    }


    component fix2Regex = Fix2Regex();
    for (var i = 0; i < fix2Len; i++) {
        fix2Regex.in[i] <== fix2Array[0 + i];
    }


    component messageUncertainty = UncertaintyExtraction(messageRange, fix3Len, fix0Len + fix1Len + fix2Len + nameMin + amountMin + messageMin, msgBytes);
    messageUncertainty.indicatorLen <== messageLen - messageMin + amountLen - amountMin + nameLen - nameMin;
    for (var i = 0; i < msgBytes; i++) {
        messageUncertainty.in[i] <== in[i];
    }
    signal fix3Array[fix3Len];
    for (var i = 0; i < fix3Len; i++) {
        fix3Array[i] <== messageUncertainty.out[i];
    }


    component fix3Regex = Fix3Regex();
    for (var i = 0; i < fix3Len; i++) {
        fix3Regex.in[i] <== fix3Array[0 + i];
    }


    component paymentUncertainty = UncertaintyExtraction(paymentRange, fix4Len, fix0Len + fix1Len + fix2Len + fix3Len + nameMin + amountMin + messageMin + paymentMin, msgBytes);
    paymentUncertainty.indicatorLen <== paymentLen - paymentMin + messageLen - messageMin + amountLen - amountMin + nameLen - nameMin;
    for (var i = 0; i < msgBytes; i++) {
        paymentUncertainty.in[i] <== in[i];
    }
    signal fix4Array[fix4Len];
    for (var i = 0; i < fix4Len; i++) {
        fix4Array[i] <== paymentUncertainty.out[i];
    }


    signal output nullifier;
    component fix4Regex = Fix4Regex();
    for (var i = 0; i < fix4Len; i++) {
        fix4Regex.in[i] <== fix4Array[0 + i];
    }
    nullifier <== fix4Regex.out;
}
