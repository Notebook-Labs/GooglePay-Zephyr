// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../dep/extract.circom";
include "../dynamic/name.circom";
include "../dynamic/amount.circom";
include "../fixedSubject/subject0Fix0.circom";
include "../fixedSubject/subject0Fix1.circom";
include "../fixedSubject/subject0Fix2.circom";
include "../fixedSubject/subject0Fix3.circom";


template Subject0(msgBytes) {

    signal input in[msgBytes];
    signal input emailLen;
    signal input nameLen;
    signal input subjectAmountLen;

    var fix0Len = 3;
    var fix1Len = 67;
    var fix2Len = 2;
    var fix3Len = 2;
    var emailMin = 4;
    var emailMax = 320;
    var nameMin = 1;
    var nameMax = 300;
    var amountMin = 1;
    var amountMax = 8;




    var emailRange = emailMax - emailMin + 1;
    var nameRange = emailRange + nameMax - nameMin;
    var amountRange = nameRange + amountMax - amountMin;


    component subject0Fix0Regex = Subject0Fix0Regex();
    for (var i = 0; i < fix0Len; i++) {
        subject0Fix0Regex.in[i] <== in[0 + i];
    }


    component emailUncertainty = UncertaintyExtraction(emailRange, fix1Len, fix0Len + emailMin, msgBytes);
    emailUncertainty.indicatorLen <== emailLen - emailMin;
    for (var i = 0; i < msgBytes; i++) {
        emailUncertainty.in[i] <== in[i];
    }
    signal fix1Array[fix1Len];
    for (var i = 0; i < fix1Len; i++) {
        fix1Array[i] <== emailUncertainty.out[i];
    }


    component subject0Fix1Regex = Subject0Fix1Regex();
    for (var i = 0; i < fix1Len; i++) {
        subject0Fix1Regex.in[i] <== fix1Array[0 + i];
    }


    signal output name[nameMax];
    component nameRegex = NameRegex(nameRange + nameMin, nameMax);
    for (var i = 0; i < nameRange + nameMin; i++) {
        nameRegex.in[i] <== in[fix0Len + emailMin + fix1Len + i];
    }
    nameRegex.start <== emailLen - emailMin;
    nameRegex.len <== nameLen;
    for (var i = 0; i < nameMax; i++) {
        name[i] <== nameRegex.out[i];
     }


    component nameUncertainty = UncertaintyExtraction(nameRange, fix2Len, fix0Len + fix1Len + emailMin + nameMin, msgBytes);
    nameUncertainty.indicatorLen <== nameLen - nameMin + emailLen - emailMin;
    for (var i = 0; i < msgBytes; i++) {
        nameUncertainty.in[i] <== in[i];
    }
    signal fix2Array[fix2Len];
    for (var i = 0; i < fix2Len; i++) {
        fix2Array[i] <== nameUncertainty.out[i];
    }


    component subject0Fix2Regex = Subject0Fix2Regex();
    for (var i = 0; i < fix2Len; i++) {
        subject0Fix2Regex.in[i] <== fix2Array[0 + i];
    }


    signal output amount;
    component amountRegex = AmountRegex(amountRange + amountMin);
    for (var i = 0; i < amountRange + amountMin; i++) {
        amountRegex.in[i] <== in[fix0Len + fix1Len + fix2Len + emailMin + nameMin + i];
    }
    amountRegex.start <== emailLen - emailMin + nameLen - nameMin;
    amountRegex.len <== subjectAmountLen;
    amount <== amountRegex.out;


    component amountUncertainty = UncertaintyExtraction(amountRange, fix3Len, fix0Len + fix1Len + fix2Len + emailMin + nameMin + amountMin, msgBytes);
    amountUncertainty.indicatorLen <== subjectAmountLen - amountMin + nameLen - nameMin + emailLen - emailMin;
    for (var i = 0; i < msgBytes; i++) {
        amountUncertainty.in[i] <== in[i];
    }
    signal fix3Array[fix3Len];
    for (var i = 0; i < fix3Len; i++) {
        fix3Array[i] <== amountUncertainty.out[i];
    }


    component subject0Fix3Regex = Subject0Fix3Regex();
    for (var i = 0; i < fix3Len; i++) {
        subject0Fix3Regex.in[i] <== fix3Array[0 + i];
    }
}
