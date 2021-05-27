#!/usr/bin/env bash
## 原文件地址：https://github.com/monk-coder/dust的shell_script_mod.sh
## 请注意，已做多处修改，与原文件不同

function monkcoder(){
    # https://github.com/monk-coder/dust
    rm -rf ./monkcoder ./scripts/monkcoder_*
    git clone https://github.com/monk-coder/dust.git ./monkcoder/
    # 拷贝脚本
    for jsname in $(find ./monkcoder -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} ./scripts/monkcoder_${jsname##*/}; done
    # 匹配js脚本中的cron设置定时任务
    for jsname in $(find ./monkcoder -name "*.js" | grep -vE "\/backup\/"); do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron bash jd monkcoder_${jsname##*/}" >> ./config/crontab.list
        test -z "$jsnamecron" || echo "$jsnamecron bash jd monkcoder_${jsname##*/}" >> /etc/crontabs/root
    done
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d ./jd_diy ]] && mkdir ./jd_diy && cp -rf ./scripts/docker/* /jd_diy
    # DIY脚本执行前后信息
    a_jsnum=$(ls -l ./scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l ./scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    monkcoder
    b_jsnum=$(ls -l ./scripts | grep -oE "^-.*js$" | wc -l)
    b_jsname=$(ls -l ./scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    # DIY脚本更新TG通知
    info_more=$(echo $a_jsname  $b_jsname | tr " " "\n" | sort | uniq -c | grep -oE "1 .*$" | grep -oE "[^ ]*js$" | tr "\n" " ")
    [[ "$a_jsnum" == "0" || "$a_jsnum" == "$b_jsnum" ]] || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=DIY脚本更新完成：$a_jsnum $b_jsnum $info_more" >/dev/null
    # LXK脚本更新TG通知
    lxktext="$(diff ./jd_diy/crontab_list.sh ./scripts/docker/crontab_list.sh | grep -E "^[+-]{1}[^+-]+" | grep -oE "node.*\.js" | cut -d/ -f3 | tr "\n" " ")"
    test -z "$lxktext" || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=LXK脚本更新完成：$(cat /jd_diy/crontab_list.sh | grep -vE "^#" | wc -l) $(cat ./scripts/docker/crontab_list.sh | grep -vE "^#" | wc -l) $lxktext" >/dev/null
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf ./scripts/docker/* ./jd_diy
}

main
