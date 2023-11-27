# Google Pay Circuits

On Google Pay, selling is an interactive process where sellers have to send requests to buyers. This is because Google Pay has no inherent unique user identifier which could be used to safely identify a seller. A buyer will first signal an intent to buy on the Zephyr Sybil contract, the seller will then confirm the order by commiting to a transaction ID obtained by sending a request to the buyer on Google Pay. The buyer will then complete the request and recieve the USDC.

## Constraints
Simply hashing the GooglePay email is ~40 million constraints. The Google Pay templating circuits correspond to less than 5% of the total constraints. We are actively working to optimize the hashing templates.

## General Circuit Paradigm

We build our circuits with two intentions in mind:
- (**Completeness** & **Soundness**) Given the current Google Pay email template, honest provers' emails should always generate valid proofs and malicious provers should never be able to generate a valid proof.
- (**Safeguard**) Given the slightest change in the email template by Google Pay, the proof should always fail. We made this design choice because it is impossible to predict was potential exploits could come up if Google Pay changed their template therefore we would rather all proofs fail and we create a new circuit adapted for the new template.

Given this, we detail that the following parts of the circuit are done for completeness and soundness:
- Verifying the RSA signature.
- Computing the hash of the body.
- Extracting the body hash from the header and checking equality with the body hash.
Extracting the relevant information from the body.

The following parts are done as a safeguard:
- Constraining all the fix html sections of the Google Pay body.
- Extracting the name and amount from the subject and checking against the values extracted from the body.

## Zephyr-GooglePay Licensing

Select components of Zephyr-GooglePay, which are marked with "SPDX-License-Identifier: BUSL-1.1", were launched under a Business Source License 1.1 (BUSL 1.1).

The license limits use of the Zephyr source code in a commercial or production setting until January 1st, 2026. After this, the license will convert to a general public license. This means anyone can fork the code for their own use — as long as it is kept open source.

In addition, certain parts of Zephyr-GooglePay are derived from other sources and are separately licensed under the GNU General Public License (GPL-3.0-only). These components are explicitly marked with "SPDX-License-Identifier: GPL-3.0-only" and are subject to the terms of the GNU GPL. The full text of the GPL license can be found in the LICENSE-GPL file in the root directory of this project.

## Why We're Starting with a Clean Repository

In our journey to make this project open source, we've decided to start with a clean slate. This approach allows us to ensure that the repository is streamlined, focused, and free from any developmental artifacts that might be confusing or irrelevant to the community. We believe that this will facilitate a clearer understanding of the project and encourage more meaningful contributions from the community. While this means we lose the historical commit data, we think the trade-off is worth it for the sake of clarity and ease of contribution. Our goal is to present a more approachable, well-organized codebase that reflects the current state of the project and aligns more closely with open-source best practices. We appreciate your understanding and are excited to see how this project evolves with your valuable input!
