// SPDX-License-Identifier: GPL-3.0-only

pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../dep/sha256.circom";
include "../dep/rsa.circom";
include "../dep/base64.circom";
include "../dep/utils.circom";
include "../dep/modulusHash.circom";
include "../dep/bodyHashRegex.circom";
include "./wrappers/base64Parse.circom";
include "./wrappers/decoded.circom";
include "./wrappers/subject0.circom";
include "./wrappers/encodedSubject.circom";


template googlePay(maxHeaderBytes, maxBodyBytes, n, k, keyLenBytes) {

	// support for 1024, 2048 bit rsa keys
	assert(keyLenBytes >= 128);
	assert(keyLenBytes <= 256);
	assert(keyLenBytes % 64 == 0);

	assert(maxHeaderBytes % 64 == 0);
	assert(maxHeaderBytes > 0);
	assert(maxHeaderBytes < 4096); // Just to ensure maxHeaderBits is a field element. In practice can be larger

	assert(maxBodyBytes % 64 == 0);
	assert(maxBodyBytes > 0);

	assert(n * k > keyLenBytes * 8); // ensure we have enough bits to store the modulus
	assert(k * 2 < 255); 
	assert(k >= 0);
	assert(n >= 0);
	assert(n < 122); // not a perfect bound but we need 2n + log(k) < 254 

	var maxHeaderBits = maxHeaderBytes * 8;

    signal input subjectSelect;

    signal input mimeLen;
    signal input encodedLen;
    signal input messageLen;
    signal input paymentLen;
    signal input amountLen;

    // encoded name
    signal input email1Len;
    signal input subjectEncodedLen;
    signal input name1Len;
    signal input subjectAmount1Len;

    // normal name
    signal input email0Len;
    signal input name0Len;
    signal input subjectAmount0Len;


    signal input proverAddress;
    signal input inPadded0[maxHeaderBytes];
    signal input inPadded1[maxHeaderBytes];
    signal input inBodyPadded[maxBodyBytes];

    var messageMin = 8;
    var messageMax = 4100;
    var paymentMin = 50;
    var paymentMax = 75;
    var emailMin = 4;
    var emailMax = 320;
    var nameMin = 1;
    var nameMax = 300;
    var amountMin = 1;
    var amountMax = 8;
    var mimeMin = 4;
    var mimeMax = 68;
    var encodedMin = 4681;
    var encodedMax = 11645;

    var subjectEncodedMin = 10;
    var subjectEncodedMax = 532;

	var decodedMax = 8510;

	component mimeCheck = MaxMinCheck(7, mimeMin, mimeMax);
	mimeCheck.inLen <== mimeLen;

	component base64Check = MaxMinCheck(14, encodedMin, encodedMax);
	base64Check.inLen <== encodedLen;

	component messageCheck = MaxMinCheck(13, messageMin, messageMax);
	messageCheck.inLen <== messageLen;

	component paymentCheck = MaxMinCheck(7, paymentMin, paymentMax);
	paymentCheck.inLen <== paymentLen;

	component amountCheck = MaxMinCheck(4, amountMin, amountMax);
	amountCheck.inLen <== amountLen;

    component email0Check = MaxMinCheck(9, emailMin, emailMax);
	email0Check.inLen <== email0Len;

	component name0Check = MaxMinCheck(9, nameMin, nameMax);
	name0Check.inLen <== name0Len;

	component subjectAmount0Check = MaxMinCheck(4, amountMin, amountMax);
	subjectAmount0Check.inLen <== subjectAmount0Len;

    component email1Check = MaxMinCheck(9, emailMin, emailMax);
	email1Check.inLen <== email1Len;

	component name1Check = MaxMinCheck(9, nameMin, nameMax);
	name1Check.inLen <== name1Len;

	component subjectAmount1Check = MaxMinCheck(4, amountMin, amountMax);
	subjectAmount1Check.inLen <== subjectAmount1Len;

    component subjectEncodedCheck = MaxMinCheck(10, subjectEncodedMin, subjectEncodedMax);
	subjectEncodedCheck.inLen <== subjectEncodedLen;

    //
	// SUBJECT 0 REGEX
	//
	component subject0Regex = Subject0(maxHeaderBytes);
	for (var i = 0; i < maxHeaderBytes; i++) {
		subject0Regex.in[i] <== inPadded0[i];
	}
	subject0Regex.emailLen <== email0Len;
	subject0Regex.nameLen <== name0Len;
	subject0Regex.subjectAmountLen <== subjectAmount0Len;

    //
	// SUBJECT Encoded REGEX
	//
	component subject1Regex = EncodedSubject(maxHeaderBytes);
	for (var i = 0; i < maxHeaderBytes; i++) {
		subject1Regex.in[i] <== inPadded1[i];
	}
	subject1Regex.emailLen <== email1Len;
	subject1Regex.nameLen <== name1Len;
	subject1Regex.subjectAmountLen <== subjectAmount1Len;
    subject1Regex.subjectEncodedLen <== subjectEncodedLen;

    // Select the amount
    component subjectAmountEqs[2];
	signal subjectAmountSums[2+1];
	signal subjectAmountSignals[2];

	subjectAmountSignals[0] <== subject0Regex.amount;
	subjectAmountSignals[1] <== subject1Regex.amount;
	subjectAmountSums[0] <== 0;

	for (var i = 0; i < 2; i ++) {
		subjectAmountEqs[i] = IsEqual();
		subjectAmountEqs[i].in[0] <== i;
		subjectAmountEqs[i].in[1] <== subjectSelect;

		subjectAmountSums[i+1] <== subjectAmountSums[i] + subjectAmountEqs[i].out * subjectAmountSignals[i];

	}

	signal subjectAmount <== subjectAmountSums[2];

    // select the name

    component subjectNameEqs[2];
	signal subjectNameSums[nameMax][2+1];
	signal subjectNameArrays[2][nameMax];

	for (var k=0; k<nameMax; k++) {
		subjectNameArrays[0][k] <== subject0Regex.name[k];
		subjectNameArrays[1][k] <== subject1Regex.name[k];
	}

	for (var k=0; k<nameMax; k++) {
		subjectNameSums[k][0] <== 0;
	}

	for (var i = 0; i < 2; i ++) {
		subjectNameEqs[i] = IsEqual();
		subjectNameEqs[i].in[0] <== i;
		subjectNameEqs[i].in[1] <== subjectSelect;

		for (var k=0; k<nameMax; k++) {
			subjectNameSums[k][i+1] <== subjectNameSums[k][i] + subjectNameEqs[i].out * subjectNameArrays[i][k];
		}

	}

	// output the final sums
	signal subjectName[nameMax];
	for (var k=0; k<nameMax; k++) {
		subjectName[k] <== subjectNameSums[k][2];
	}

    // Select the name selector
    component nameLenEqs[2];
	signal nameLenSums[2+1];
	signal nameLenSignals[2];

	nameLenSignals[0] <== name0Len;
	nameLenSignals[1] <== name1Len;
	nameLenSums[0] <== 0;

	for (var i = 0; i < 2; i ++) {
		nameLenEqs[i] = IsEqual();
		nameLenEqs[i].in[0] <== i;
		nameLenEqs[i].in[1] <== subjectSelect;

		nameLenSums[i+1] <== nameLenSums[i] + nameLenEqs[i].out * nameLenSignals[i];

	}

	signal nameLen <== nameLenSums[2];

    // Select the correct subject
    component inSubjectEqs[2];
	signal inSubjectSums[maxHeaderBytes][2+1];
	signal inSubjectArrays[2][maxHeaderBytes];

	for (var k=0; k<maxHeaderBytes; k++) {
		inSubjectArrays[0][k] <== inPadded0[k];
		inSubjectArrays[1][k] <== inPadded1[k];
	}

	for (var k=0; k<maxHeaderBytes; k++) {
		inSubjectSums[k][0] <== 0;
	}

	for (var i = 0; i < 2; i ++) {
		inSubjectEqs[i] = IsEqual();
		inSubjectEqs[i].in[0] <== i;
		inSubjectEqs[i].in[1] <== subjectSelect;

		for (var k=0; k<maxHeaderBytes; k++) {
			inSubjectSums[k][i+1] <== inSubjectSums[k][i] + inSubjectEqs[i].out * inSubjectArrays[i][k];
		}

	}

	// output the final sums
	signal inPadded[maxHeaderBytes];
	for (var k=0; k<maxHeaderBytes; k++) {
		inPadded[k] <== inSubjectSums[k][2];
	}
	
	//
	// CHECK INPUTS AND HASH
	//
	signal input inLenPaddedBytes0; // length of in header data including the padding

	component sha0 = sha256(maxHeaderBits);

	// Need to input bits to sha256. Also servers as a range check
	component inPadded0Bits[maxHeaderBytes];

	for (var i = 0; i < maxHeaderBytes; i++) {
		inPadded0Bits[i] = Num2Bits(8);
		inPadded0Bits[i].in <== inPadded[i];

		for (var j = 0; j < 8; j++) {
			// we need to unflip the bits as sha0 treats the first bit as the MSB
			sha0.paddedIn[i*8+j] <== inPadded0Bits[i].out[7-j]; 
		}
	}

	sha0.inLenPaddedBits <== inLenPaddedBytes0 * 8;

	//
	// VERIFY RSA SIGNATURE
	//

	// pubkey, verified with smart contract oracle
	signal input modulus0[k]; 
	signal input signature0[k];

	// range check the public key
	component modulus0RangeCheck[k];
	for (var i = 0; i < k; i++) {
		modulus0RangeCheck[i] = Num2Bits(n);
		modulus0RangeCheck[i].in <== modulus0[i];
	}

	// range check the signature
	component signature0RangeCheck[k];
	for (var i = 0; i < k; i++) {
		signature0RangeCheck[i] = Num2Bits(n);
		signature0RangeCheck[i].in <== signature0[i];
	}

	// verify the rsa signature of the first key
	component rsa0 = RSAVerify65537(n, k, keyLenBytes);
	for (var i = 0; i < 256; i++) {
		rsa0.baseMessage[i] <== sha0.out[i];
	}
	for (var i = 0; i < k; i++) {
		rsa0.modulus[i] <== modulus0[i];
	}
	for (var i = 0; i < k; i++) {
		rsa0.signature[i] <== signature0[i];
	}

	//
	// HASH PUBLIC KEYS 
	//

	component shaMod = ModulusShaSingle(n, k, keyLenBytes);
	for (var i = 0; i < k; i++) {
		shaMod.modulus0[i] <== modulus0[i];
	}

	//
	// BODY HASH REGEX 0: 
	//

	var lenShaB64 = 44;  
	component bodyHashRegex0 = BodyHashRegex(maxHeaderBytes, lenShaB64);
	for (var i = 0; i < maxHeaderBytes; i++) {
		bodyHashRegex0.msg[i] <== inPadded[i];
	}

	//
	// HASH BODY
	//

	signal input inBodyLenPaddedBytes;

	var maxBodyBits = maxBodyBytes * 8;
	component shaBody = sha256(maxBodyBits);

	// Need to input bits to sha256. Also servers as a range check
	component inBodyPaddedBits[maxBodyBytes];

	for (var i = 0; i < maxBodyBytes; i++) {
		inBodyPaddedBits[i] = Num2Bits(8);
		inBodyPaddedBits[i].in <== inBodyPadded[i];

		for (var j = 0; j < 8; j++) {
			// we need to unflip the bits as sha256 treats the first bit as the MSB
			shaBody.paddedIn[i*8+j] <== inBodyPaddedBits[i].out[7-j]; 
		}
	}

	shaBody.inLenPaddedBits <== inBodyLenPaddedBytes * 8;

	//
	// VERIFY HASH OF BODY MATCHES BODY HASH EXTRACTED FROM HEADER 
	//

	component shaB64 = Base64Decode(lenShaB64); 
	for (var i = 0; i < lenShaB64; i++) {
		shaB64.in[i] <== bodyHashRegex0.bodyHashOut[i];
	}

	for (var i = 0; i < 256; i++) {
		shaB64.out[i] === shaBody.out[i];
	}

	//
	// BASE 64 PARSING REGEX
	//
	component base64Parse = Base64Parse(maxBodyBytes);
	for (var i = 0; i < maxBodyBytes; i++) {
		base64Parse.in[i] <== inBodyPadded[i];
	}
	base64Parse.mimeLen <== mimeLen;
	base64Parse.encodedLen <== encodedLen;

	//
	// DECODED REGEX
	//
	component decodedRegex = Decoded(decodedMax);
	for (var i = 0; i < decodedMax; i++) {
		decodedRegex.in[i] <== base64Parse.decoded[i];
	}
	decodedRegex.nameLen <== nameLen;
	decodedRegex.amountLen <== amountLen;
	decodedRegex.messageLen <== messageLen;
	decodedRegex.paymentLen <== paymentLen;

	//
	// EQUALITY CONSTRAIN EXTRACTED NAME AND AMOUNT WITH SUBJECT AND BODY
	//
	for (var i = 0; i < nameMax; i++) {
		subjectName[i] === decodedRegex.name[i];
	}
	subjectAmount === decodedRegex.amount;


	//
	// COMPUTE THE OUTPUTTED COMMITMENT
	//
	component megaHash = Sha256(544);

	// add modulus hash to mega hash
	for (var i = 0; i < 256; i++) {
		megaHash.in[i] <== shaMod.out[i];
	}

	component proverAddressBits160 = Num2Bits(160);
	proverAddressBits160.in <== proverAddress;
	for (var i = 0; i < 160; i++) {
		megaHash.in[256 + i] <== proverAddressBits160.out[160 - 1 - i];
	}

	//96 bits as log(36)/log(2)*17 < 96
	component nullifierBits96 = Num2Bits(96);
	nullifierBits96.in <== decodedRegex.nullifier;
	for (var i = 0; i < 96; i++) {
		megaHash.in[416 + i] <== nullifierBits96.out[96 - 1 - i];
	}

	component bodyAmountBits32 = Num2Bits(32);
	bodyAmountBits32.in <== decodedRegex.amount;
	for (var i = 0; i < 32; i++) {
		megaHash.in[512 + i] <== bodyAmountBits32.out[32 - 1 - i];
	}

	signal output outputHash;

	component megaHashBits2Num = Bits2Num(253);
	for (var i = 0; i < 253; i++) {
		megaHashBits2Num.in[i] <== megaHash.out[252 - i];
	}

	outputHash <== megaHashBits2Num.out;
}


component main = googlePay(1024, 60864, 121, 17, 256);
