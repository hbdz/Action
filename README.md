# Action
github action 的定时执行并非准时运行，而是比你设定的时间要晚约几十分钟至两小时（推测是要排队）。

yml配置文件中，定时设置的时间是UTC时间，如果要修改，要将北京时间减8小时，例如：修改为每天9:20执行，需要写 - cron: "20 1 * * *"

如果项目连续60天未有任何改动，action 会被终止，所以每隔一段时间要有变动，比如改一改 README.md 文件。
