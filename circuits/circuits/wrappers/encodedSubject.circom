// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../dep/extract.circom";
include "../../dep/base64.circom";
include "../dynamic/name.circom";
include "../dynamic/amount.circom";
include "../fixedSubject/subject0Fix0.circom";
include "../fixedSubject/subject0Fix2.circom";
include "../fixedSubject/subject0Fix3.circom";
include "../fixedSubject/subjectEncodedFix1.circom";
include "../fixedSubject/subjectEncodedFix2.circom";
include "../fixedSubject/subjectEncodedFix3.circom";
include "../dynamic/base64Carriage.circom";

template EncodedSubject(msgBytes) {

    signal input in[msgBytes];
    signal input emailLen;
    signal input subjectEncodedLen;
    signal input nameLen;
    signal input subjectAmountLen;

    var fix0Len = 3;
    var fix1EncodedLen = 68;
    var fix2EncodedLen = 9;
    var fix3EncodedLen = 4;
    var fix2Len = 2;
    var fix3Len = 2;
    var emailMin = 4;
    var emailMax = 320;

    var encodedMin = 10;
    var encodedMax = 532;
    var decodedMax = 397;

    var nameMin = 1;
    var nameMax = 300;
    var amountMin = 1;
    var amountMax = 8;




    var emailRange = emailMax - emailMin + 1;
    var encodedRange = emailRange + encodedMax - encodedMin;

    var nameRange = nameMax - nameMin + 1;
    var amountRange = nameRange + amountMax - amountMin;


    component subject0Fix0Regex = Subject0Fix0Regex();
    for (var i = 0; i < fix0Len; i++) {
        subject0Fix0Regex.in[i] <== in[0 + i];
    }

    // Extract fix 1 + encoded array
    component emailUncertainty = UncertaintyExtraction(emailRange, fix1EncodedLen + encodedMax, fix0Len + emailMin, msgBytes);
    emailUncertainty.indicatorLen <== emailLen - emailMin;
    for (var i = 0; i < msgBytes; i++) {
        emailUncertainty.in[i] <== in[i];
    }

    signal fix1EncodedArray[fix1EncodedLen];
    for (var i = 0; i < fix1EncodedLen; i++) {
        fix1EncodedArray[i] <== emailUncertainty.out[i];
    }

    component subject0EncodedFix1Regex = Subject0EncodedFix1Regex();
    for (var i = 0; i < fix1EncodedLen; i++) {
        subject0EncodedFix1Regex.in[i] <== fix1EncodedArray[0 + i];
    }

    // Extract the final fix
    component encodedUncertainty = UncertaintyExtraction(encodedRange, fix3EncodedLen, fix0Len + emailMin + fix1EncodedLen + encodedMin, msgBytes);
    encodedUncertainty.indicatorLen <== subjectEncodedLen - encodedMin + emailLen - emailMin;
    for (var i = 0; i < msgBytes; i++) {
        encodedUncertainty.in[i] <== in[i];
    }

    signal fix3EncodedArray[fix3EncodedLen];
    for (var i = 0; i < fix3EncodedLen; i++) {
        fix3EncodedArray[i] <== encodedUncertainty.out[i];
    }

    component subject0EncodedFix3Regex = Subject0EncodedFix3Regex();
    for (var i = 0; i < fix3EncodedLen; i++) {
        subject0EncodedFix3Regex.in[i] <== fix3EncodedArray[0 + i];
    }


    //use Base64Carriage to remove carriage characters
    signal encoded[encodedMax];
    component base64Carriage = Base64CarriageSubject(encodedMax);
    for (var i = 0; i < encodedMax; i++) {
        base64Carriage.in[i] <== emailUncertainty.out[fix1EncodedLen + i];
    }

    base64Carriage.len <== subjectEncodedLen;
    for (var i = 0; i < encodedMax; i++) {
        encoded[i] <== base64Carriage.noCarriage[i];
    }

    component decode = Base64VariableDecode(encodedMax);
    for (var i = 0; i < encodedMax; i++) {
        decode.in[i] <== encoded[i];
    }
    decode.len <== base64Carriage.rotatedLen;

    signal decoded[decodedMax];
    for (var i = 0; i < decodedMax; i++) {
        decoded[i] <== decode.out[i];
    }

    component subject0EncodedFix2Regex = Subject0EncodedFix2Regex();
    for (var i = 0; i < fix2EncodedLen; i++) {
        subject0EncodedFix2Regex.in[i] <== decoded[0 + i];
    }


    signal output name[nameMax];
    component nameRegex = NameRegex(nameRange + nameMin, nameMax);
    for (var i = 0; i < nameRange + nameMin; i++) {
        nameRegex.in[i] <== decoded[fix2EncodedLen + i];
    }
    nameRegex.start <== 0;
    nameRegex.len <== nameLen;
    for (var i = 0; i < nameMax; i++) {
        name[i] <== nameRegex.out[i];
     }


    component nameUncertainty = UncertaintyExtraction(nameRange, fix2Len, fix2EncodedLen + nameMin, decodedMax);
    nameUncertainty.indicatorLen <== nameLen - nameMin;
    for (var i = 0; i < decodedMax; i++) {
        nameUncertainty.in[i] <== decoded[i];
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
        amountRegex.in[i] <== decoded[fix2EncodedLen + nameMin + fix2Len + i];
    }
    amountRegex.start <== nameLen - nameMin;
    amountRegex.len <== subjectAmountLen;
    amount <== amountRegex.out;

}

//component main = EncodedSubject(1344);
