package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"github.com/Mr-Javadian/honest-ui/model/constant"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show version",
	Long:  "Show version.",
	Run:   runVersion,
}

func init() {
	rootCmd.AddCommand(versionCmd)
}

func runVersion(cmd *cobra.Command, args []string) {
	fmt.Println("honest-ui version", constant.Version)
}
