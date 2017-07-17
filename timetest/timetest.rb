
=begin

サーバー時間変更テストフレームワーク　[プロトタイプ]
 * サーバーの時間ごとで振る舞いをテストする
  * 例
   * cron設定されているプログラム
   * atコマンドで設定されているプログラム
   * 一定時間のWEBページの表示変更

 * 設定
  * conf/config.ymlにユーザー設定
   * 開始日時・終了日時・時間をすすめる間隔・テストするプログラム等
  * conf/hosts テストする対象サーバー設定
   * Ansibleの設定ファイルになる。

* 用法
 * ruby timetest.rb
 * option
  * --debug : デバッグモード
  * --config [config file]
  * --hosts [hosts file]
  
 * TODO 
  * 例外発生時のntpdateの実行 ctl+Cの場合等
  * ansibleを使っているが、Specinfraを使えないか検討
   * ansibleは使いやすいが、冪等性は不要。ansibleが重たい。OS抽象化と複数リモートサーバーへのコマンド実行が簡単にできれば用をたすため。
  * ansibleコマンドがべた書き　外に出すなど。
  * rspecでテストをしているが、設定時間によって実行するテストを変更する機能を追加
  * cronの実行結果を自動的に取得して結果を出力する機能を追加
  * すべて完了したときに実行するテストの機能を追加
  
 * MEMO
  * YAML.loadでは文字列のハッシュしか扱えない。シンボルを使えない。そのためシンボルを使っていない。

=end


###########################################
# config
require "bundler/setup"
require 'yaml'
require 'fileutils'
require 'time'
require 'thor'


class Timetest < Thor
  
  default_command :exec
  desc "exec usage" , "exec desc"
  option  :config, :aliases => :c, :default => "config.yml"
  option  :hosts , :aliases => :h, :default => "hosts"
  option  :debug , :aliases => :d, :type => :boolean
  
  def exec()
    
    puts "* start"
    
    puts "** set_config start"
    set_config()
    
    puts "** set_time_array start"
    set_time_array()
    
    puts "** exec_each_time start"
    exec_each_time()
    
    
    puts "** exec_ntpdate start"
    exec_ntpdate()
    
    puts "* end"  
  
  end

  private
    
    def set_config()
      if( options[:debug] == true )
        @debug = true
        
        @ansible_debug_option = "-v"
      end
      
      exec_path = File.expand_path(File.dirname(__FILE__))
      conf_path = exec_path + '/conf'
      
      ################################################
      # 設定ファイル
      config_file = options["config"]
      
      unless(File.exist?(conf_path  + '/' + config_file) )
        puts "[error] config file not exist. config_flie: " + conf_path  + '/' + config_file
        exit
      end
      puts "*** set config_flie: " + conf_path  + '/' + config_file
      
      ################################################
      # システム設定ファイル
      system_config_file = 'system_config.yml'
      
      #### system_config.ymlファイル
      
      
      unless(File.exist?(conf_path  + '/' + system_config_file) )
        puts "[error] system_config file not exist. system_config_flie: " + conf_path  + '/' + system_config_file
        exit
      end
      puts "*** system_config_flie: " + conf_path  + '/' + system_config_file
      
      ################################################
      #### 対象サーバーリストファイル
      hosts  =options['hosts']
      
      
      unless(File.exist?( conf_path + '/' + hosts) )
        puts "[error] hosts_file file not exist. hosts_file: " +conf_path + '/' +  hosts
        exit
      end
      puts "*** hosts_file: "  + conf_path + '/' +  hosts
      ################################################
      # 設定ファイル読込
      
      @config = YAML.load_file(conf_path + '/' + config_file)
      @config.merge( YAML.load_file(conf_path + '/' + system_config_file) )
      
      @config["hosts_file"] = hosts
      @config["conf_path"]  = conf_path
    end
    
    def set_time_array
      
      startday = Time.parse(@config["startday"])
      puts "*** startday: " + startday.strftime("%Y-%m-%d %H:%M:%S")
      
      endday   = Time.parse(@config["endday"])
      puts "*** endday:  " + endday.strftime("%Y-%m-%d %H:%M:%S")
      
      ###########################################
      # 設定時間配列作成
      n=0
      c_time = startday
      
      @time_array =[]
      while c_time <= endday do
        @time_array << c_time
        c_time = c_time + @config["interval"]
        n = n+1
        if( n > 30000) # 無限ループ回避　安全弁
          puts "error"
          exit
        end
      end
      
      ######################
      # 特殊日付　追加 1時間ごとではない番組開始・終了日時を追加しておく。
      if(@debug)
        p @config["addday"]
      end
      
      @config["addday"].each  do |c_addday|
      
        c = Time.parse(c_addday)
        @time_array << c
      end
      
      ###########################################
      @time_array = @time_array.sort
      
      puts"*** setting time"
      @time_array.each do |t|
        puts t
      end
    end
    
    def exec_each_time()
      @time_array.each do |c_time|
      
        c_timef = c_time.strftime("%Y-%m-%d %H:%M:%S")
      
        puts "*** c_time:" + c_timef
        
        if c_time < Time.parse(@config["startday"])
          puts "*** c_time too eary. next #{c_timef}"
          next
        end
        
        if c_time > Time.parse(@config["endday"])
          puts "*** c_time too late. next #{c_timef}"
          next
        end
        
        # yaml設定　スキップする時間 
        check_time = c_time.strftime("%H:%M") #=> "21:30"
        skip_flag = 0
      
        @config["skiptime"].each do |s_time|
          puts "*** #{check_time} : #{s_time}" if @debug
      
          if check_time == s_time
            puts "*** next cause : #{check_time}" if @debug
            skip_flag = 1
            next
          end
        end
        if skip_flag == 1
          puts "*** skip time for config : #{check_time}"
          next
        end
        
        # 時間設定
        c_time_before = c_time - @config["time_before_set"]  # cronを動かすために一定時間前に設定する。
        
        c_string = c_time_before.strftime("%Y-%m-%d %H:%M:%S") #=> "2009-03-01 00:31:21"
        
        cmd_set_time_c_cmd  = "ansible-playbook #{@config['conf_path']}/changetime.yml -i #{@config['conf_path']}/#{@config['hosts_file']}  --extra-vars \"var_time='\\\"#{c_string}\\\"'\"  #{@ansible_debug_option}  " #=>ok
        
        puts cmd_set_time_c_cmd
        
        system(cmd_set_time_c_cmd)
        
        result = system(cmd_set_time_c_cmd) 
        
        p result
        # crond atd restart
        system("ansible-playbook #{@config['conf_path']}/restart.yml -i #{@config['conf_path']}/#{@config['hosts_file']}  #{@ansible_debug_option} ")
        
        puts "*** sleep: " + @config["time_sleep_sec"].to_s + "sec"
        sleep(@config["time_sleep_sec"])
        
        # 時間設定後、実行するプログラム群
        @config["post_exec"].each do |c_exec|
          puts "*** exec #{c_exec}"
          system(c_exec)
        end
      end
      
    end
    
    # 現在日時にもどす。
    def exec_ntpdate()
      result = system("ansible-playbook #{@config['conf_path']}/ntp.yml -i #{@config['conf_path']}/#{@config['hosts_file']}   #{@ansible_debug_option}  ")
      p result
    end
    
end

Timetest.start(ARGV)
