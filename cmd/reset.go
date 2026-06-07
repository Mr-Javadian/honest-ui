package cmd

import (
	"fmt"
	"github.com/Mr-Javadian/honest-ui/dao"
	"github.com/Mr-Javadian/honest-ui/util"
	"github.com/spf13/cobra"
	"os"
)

var resetCmd = &cobra.Command{
	Use:   "reset",
	Short: "Reset username and password",
	Long:  "Reset username and password.",
	Run:   runReset,
}

func init() {
	rootCmd.AddCommand(resetCmd)
}

func runReset(cmd *cobra.Command, args []string) {
	username, err := util.RandomString(12)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	password, err := util.RandomString(20)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	if err = dao.InitSqliteDB(); err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	if err = dao.UpdateAccount([]int64{1}, map[string]interface{}{
		"username": username,
		"pass":     util.SHA224String(password),
		"con_pass": ""}); err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	fmt.Println(fmt.Sprintf("Honest-UI Login Username: %s", username))
	fmt.Println(fmt.Sprintf("Honest-UI Login Password: %s", password))
}
