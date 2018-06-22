#!/usr/bin/env bash

make proof_checker
for i in {1..6}
do
    ./proof_checker.native tests/in$i results/out$i
done
