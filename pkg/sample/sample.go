package main

import (
	"fmt"
	"os"
)

func RunSampleFn() bool {
	fmt.Println("Sample function to verify coverage")
	if os.Getenv("ENV") == "dev" {
		fmt.Println("Sample condition to skip coverage")
	}
	return true
}
