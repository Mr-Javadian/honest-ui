package util

import (
	"crypto/sha256"
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

const DefaultPassword = "admin"

var DefaultPasswordHash string

func init() {
	hash, err := bcrypt.GenerateFromPassword([]byte(DefaultPassword), bcrypt.DefaultCost)
	if err == nil {
		DefaultPasswordHash = string(hash)
	} else {
		h := sha256.Sum224([]byte(DefaultPassword))
		DefaultPasswordHash = fmt.Sprintf("%x", h)
	}
}

func SHA224String(password string) string {
	hash := sha256.New224()
	hash.Write([]byte(password))
	val := hash.Sum(nil)
	str := ""
	for _, v := range val {
		str += fmt.Sprintf("%02x", v)
	}
	return str
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

func CheckPassword(password, hash string) bool {
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)); err == nil {
		return true
	}
	return SHA224String(password) == hash
}

func IsDefaultPassword(password string) bool {
	return password == "" || SHA224String(password) == "02f382b76ca1ab7aa06ab03345c7712fd5b971fb0c0f2aef98bac9cd"
}
