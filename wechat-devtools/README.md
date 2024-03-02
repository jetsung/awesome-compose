# 微信开发者工具

项目地址：https://github.com/msojocs/wechat-web-devtools-linux

## 使用
1. 克隆
   ```
   git clone https://ghproxy.com/https://github.com/msojocs/wechat-web-devtools-linux.git
   ```
2. 运行 （需解决扶梯问题）
   ```
   sed -i 's#wget https://github.com#wget https://ghproxy.com/https://github.com#g' tools/rebuild-node-modules.sh

   sed -i 's#https://github.com#https://ghproxy.com/https://github.com#g' .gitmodules
   ```

3. 修复运行 BUG  
    Taro 白屏问题: https://github.com/msojocs/wechat-web-devtools-linux/issues/70
    ```
    ln -s $(pwd)/package.nw $(pwd)/nwjs/package.nw
    ```

4. 运行
    ```
    docker compose up -d
    ```

5. 添加环境变量
    ```
    # bash
    echo "export PATH=\"$(pwd)/bin:\$PATH\"" >> ~/.bashrc

    # zsh
    echo "export PATH=\"$(pwd)/bin:\$PATH\"" >> ~/.zshrc
    ```