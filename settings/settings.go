package settings

import (
	"fmt"
	"os"

	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
)

var Conf = new(AppConfig)

type AppConfig struct {
	Name                 string `mapstructure:"name"`
	Mode                 string `mapstructure:"mode"`
	Port                 int    `mapstructure:"port"`
	Version              string `mapstructure:"version"`
	StartTime            string `mapstructure:"start_time"`
	MachineID            int64  `mapstructure:"machine_id"`
	*LogConfig           `mapstructure:"log"`
	*MySQLConfig         `mapstructure:"mysql"`
	*SQLiteConfig        `mapstructure:"sqlite"`
	*PythonServiceConfig `mapstructure:"python_service"`
	*QianfanConfig       `mapstructure:"qianfan"`
	*YouTubeConfig       `mapstructure:"youtube"`
}

type LogConfig struct {
	Level      string `mapstructure:"level"`
	Filename   string `mapstructure:"filename"`
	MaxSize    int    `mapstructure:"max_size"`
	MaxAge     int    `mapstructure:"max_age"`
	MaxBackups int    `mapstructure:"max_backups"`
}

type MySQLConfig struct {
	Host         string `mapstructure:"host"`
	User         string `mapstructure:"user"`
	Password     string `mapstructure:"password"`
	DbName       string `mapstructure:"dbname"`
	Port         int    `mapstructure:"port"`
	MaxOpenConns int    `mapstructure:"max_open_conns"`
	MaxIdleConns int    `mapstructure:"max_idle_conns"`
}

type SQLiteConfig struct {
	Path string `mapstructure:"path"`
}

type PythonServiceConfig struct {
	URL     string `mapstructure:"url"`
	Timeout int    `mapstructure:"timeout"`
}

type QianfanConfig struct {
	APIKey  string `mapstructure:"api_key"`
	ChatURL string `mapstructure:"chat_url"`
}

type YouTubeConfig struct {
	APIKey string `mapstructure:"api_key"`
}

func Init() (err error) {
	// 支持命令行传入配置文件路径: ./ytchat conf/config.json
	if len(os.Args) > 1 {
		viper.SetConfigFile(os.Args[1])
	} else {
		// 明确指定配置文件路径
		viper.SetConfigFile("conf/config.json")
	}

	err = viper.ReadInConfig() // 查找并读取配置文件
	if err != nil {            // 处理读取配置文件的错误
		fmt.Printf("ReadInConfig() failed, err:%v\n", err)
		return
	}

	// 从app子节点读取配置
	if err := viper.UnmarshalKey("app", Conf); err != nil {
		fmt.Printf("viper.UnmarshalKey failed, err:%v\n", err)
		return err
	}

	// 读取其他配置节点
	if err := viper.UnmarshalKey("log", &Conf.LogConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey log failed, err:%v\n", err)
	}
	if err := viper.UnmarshalKey("mysql", &Conf.MySQLConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey mysql failed, err:%v\n", err)
	}
	if err := viper.UnmarshalKey("sqlite", &Conf.SQLiteConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey sqlite failed, err:%v\n", err)
	}
	if err := viper.UnmarshalKey("python_service", &Conf.PythonServiceConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey python_service failed, err:%v\n", err)
	}
	if err := viper.UnmarshalKey("qianfan", &Conf.QianfanConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey qianfan failed, err:%v\n", err)
	}
	if err := viper.UnmarshalKey("youtube", &Conf.YouTubeConfig); err != nil {
		fmt.Printf("viper.UnmarshalKey youtube failed, err:%v\n", err)
	}

	// 监听配置文件变化
	viper.WatchConfig()
	viper.OnConfigChange(func(in fsnotify.Event) {
		fmt.Println("配置文件修改了...")
		if err := viper.UnmarshalKey("app", Conf); err != nil {
			fmt.Printf("viper.UnmarshalKey failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("log", &Conf.LogConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey log failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("mysql", &Conf.MySQLConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey mysql failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("sqlite", &Conf.SQLiteConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey sqlite failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("python_service", &Conf.PythonServiceConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey python_service failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("qianfan", &Conf.QianfanConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey qianfan failed, err:%v\n", err)
		}
		if err := viper.UnmarshalKey("youtube", &Conf.YouTubeConfig); err != nil {
			fmt.Printf("viper.UnmarshalKey youtube failed, err:%v\n", err)
		}
	})

	return
}
