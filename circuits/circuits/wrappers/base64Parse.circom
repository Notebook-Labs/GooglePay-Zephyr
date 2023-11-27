// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../dep/extract.circom";
include "../fixedBody/fix0Raw.circom";
include "../fixedBody/fix1Raw.circom";
include "../fixedBody/fix2Raw.circom";
include "../fixedBody/fix3Raw.circom";
include "../dynamic/base64Carriage.circom";
include "../../dep/base64.circom";


template Base64Parse(msgBytes) {
    signal input in[msgBytes];
    signal input mimeLen;
    signal input encodedLen;

     //max value of encoded length without carriages
    var noCarriageMax = 11356; //=11645 - 146*2 rounded up to be divisible by 4
    var decodedMax = 8510; //per the doc
    signal output decoded[decodedMax];

    var fix0RawLen = 2;
    var fix1RawLen = 108;
    var fix2RawLen = 4;
    var fix3RawLen = 87;
    var mime1Min = 4;
    var mime1Max = 68;
    var encodedMin = 4681;
    var encodedMax = 11645;
    var mime2Min = 4;
    var mime2Max = 68;

    var mime1Range = mime1Max - mime1Min + 1;
    var encodedRange = mime1Range + encodedMax - encodedMin;
    var mime2Range = encodedRange + mime2Max - mime2Min;

    //do the initial fixed extraction and verification
    component fix0RawRegex = Fix0RawRegex();
    for (var i = 0; i < fix0RawLen; i++) {
        fix0RawRegex.in[i] <== in[0 + i];
    }

    component fix1RawUncertainty = UncertaintyExtraction(mime1Range, fix1RawLen, fix0RawLen + mime1Min, msgBytes);
    fix1RawUncertainty.indicatorLen <== mimeLen - mime1Min;
    for (var i = 0; i < msgBytes; i++) {
        fix1RawUncertainty.in[i] <== in[i];
    }
    signal fix1RawArray[fix1RawLen];
    for (var i = 0; i < fix1RawLen; i++) {
        fix1RawArray[i] <== fix1RawUncertainty.out[i];
    }


    component fix1RawRegex = Fix1RawRegex();
    for (var i = 0; i < fix1RawLen; i++) {
        fix1RawRegex.in[i] <== fix1RawArray[0 + i];
    }

    //do an uncertainty extraction first to get what to pass to base64Carriage
    component encodedUncertainty = UncertaintyExtraction(mime1Range, encodedMax, fix0RawLen + mime1Min + fix1RawLen, msgBytes);
    encodedUncertainty.indicatorLen <== mimeLen - mime1Min;
    for (var i = 0; i < msgBytes; i++) {
        encodedUncertainty.in[i] <== in[i];
    }

    //use Base64Carriage to remove carriage characters
    signal encoded[encodedMax];
    component base64Carriage = Base64Carriage(encodedMax);
    for (var i = 0; i < encodedMax; i++) {
        base64Carriage.in[i] <== encodedUncertainty.out[i];
    }

    base64Carriage.len <== encodedLen;
    for (var i = 0; i < encodedMax; i++) {
        encoded[i] <== base64Carriage.noCarriage[i];
    }

    component decode = Base64VariableDecode(noCarriageMax);
    for (var i = 0; i < noCarriageMax; i++) {
        decode.in[i] <== encoded[i];
    }
    decode.len <== base64Carriage.rotatedLen;

    
    
    for (var i = 0; i < decodedMax; i++) {
        decoded[i] <== decode.out[i];
    }

    //finish verification and extraction of fix sections
    component fix2RawUncertainty = UncertaintyExtraction(encodedRange, fix2RawLen, fix0RawLen + mime1Min + fix1RawLen + encodedMin, msgBytes);
    fix2RawUncertainty.indicatorLen <== encodedLen - encodedMin + mimeLen - mime1Min;
    for (var i = 0; i < msgBytes; i++) {
        fix2RawUncertainty.in[i] <== in[i];
    }
    signal fix2RawArray[fix2RawLen];
    for (var i = 0; i < fix2RawLen; i++) {
        fix2RawArray[i] <== fix2RawUncertainty.out[i];
    }

    component fix2RawRegex = Fix2RawRegex();
    for (var i = 0; i < fix2RawLen; i++) {
        fix2RawRegex.in[i] <== fix2RawArray[0 + i];
    }

    component mime2Uncertainty = UncertaintyExtraction(encodedRange, mime2Max, fix0RawLen + mime1Min + fix1RawLen + encodedMin + fix2RawLen, msgBytes);
    mime2Uncertainty.indicatorLen <== encodedLen - encodedMin + mimeLen - mime1Min;
    for (var i = 0; i < msgBytes; i++) {
        mime2Uncertainty.in[i] <== in[i];
    }
    signal mime2Array[mime2Max];
    for (var i = 0; i < mime2Max; i++) {
        mime2Array[i] <== mime2Uncertainty.out[i];
    }

    component fix3RawUncertainty = UncertaintyExtraction(mime2Range, fix3RawLen, fix0RawLen + mime1Min + fix1RawLen + encodedMin + fix2RawLen + mime2Min, msgBytes);
    fix3RawUncertainty.indicatorLen <== mimeLen - mime2Min + encodedLen - encodedMin + mimeLen - mime1Min;
    for (var i = 0; i < msgBytes; i++) {
        fix3RawUncertainty.in[i] <== in[i];
    }
    signal fix3RawArray[fix3RawLen];
    for (var i = 0; i < fix3RawLen; i++) {
        fix3RawArray[i] <== fix3RawUncertainty.out[i];
    }

    component fix3RawRegex = Fix3RawRegex();
    for (var i = 0; i < fix3RawLen; i++) {
        fix3RawRegex.in[i] <== fix3RawArray[0 + i];
    }

    //check that the MIME sections are equal
   component lt[mime1Max];
    for (var i = 0; i < mime1Max; i++) {
        lt[i] = LessThan(7);
        lt[i].in[0] <== i;
        lt[i].in[1] <== mimeLen;
        0 === lt[i].out * (in[i + fix0RawLen] - mime2Array[i + 0]);
    }
}
