# Run the differential test with the OpenZeppelin JS merkle tree implementation
differential-test :; forge test \
 	--ffi \
	-C differential_test/test/DifferentialTest.t.sol \
	--match-path differential_test/test/DifferentialTest.t.sol \
	-vvv

# Run the fuzz test with the OpenZeppelin multiproof prover contract
fuzz-test :; forge test \
	--match-path test/Prover.t.sol \
	-vvv 

# Run unit tests with standard test cases
unit-test :; forge test \
	--match-contract "TestRandom|TestSequential" \
	-vvv

