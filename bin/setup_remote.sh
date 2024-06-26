user=mangosteen
root=/home/$user/deploys/$version
container_name=mangosteen-prod-1
nginx_container_name=mangosteen-nginx-1
db_container_name=db-for-mangosteen

function set_env {
  name=$1
  hint=$2
  [[ ! -z "${!name}" ]] && return
  while [ -z "${!name}" ]; do
    [[ ! -z "$hint" ]] && echo "> 请输入 $name: $hint" || echo "> 请输入 $name:"
    read $name
  done
  sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
  echo "${name} 已保存至 ~/.bashrc"
}
function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

title '设置远程机器的环境变量'
set_env DB_HOST
set_env DB_PASSWORD
set_env RAILS_MASTER_KEY

title '创建数据库'
if [ "$(docker ps -aq -f name=^${DB_HOST}$)" ]; then
  echo '已存在数据库'
else
  docker run -d --name $DB_HOST \
            --network=network1 \
            -e POSTGRES_USER=mangosteen \
            -e POSTGRES_DB=mangosteen_production \
            -e POSTGRES_PASSWORD=$DB_PASSWORD \
            -e PGDATA=/var/lib/postgresql/data/pgdata \
            -v mangosteen-data:/var/lib/postgresql/data \
            postgres:14
  echo '创建成功'
fi

title 'app: docker build'
docker build $root -t mangosteen:$version

if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
  title 'app: docker rm old-app-container'
  docker rm -f $container_name
fi

title 'app: docker run'
docker run -d -p 3000:3000 \
           --network=network1 \
           --name=$container_name \
           -e DB_HOST=$DB_HOST \
           -e DB_PASSWORD=$DB_PASSWORD \
           -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
           mangosteen:$version

echo
echo "是否要更新数据库？[y/N]"
read ans
case $ans in
    y|Y|1  )  echo "yes"; title '更新数据库'; docker exec $container_name bin/rails db:create db:migrate ;;
    n|N|2  )  echo "no" ;;
    ""     )  echo "no" ;;
esac

if [ "$(docker ps -aq -f name=^${nginx_container_name}$)" ]; then
  title 'doc: docker rm nginx-old-container'
  docker rm -f $nginx_container_name
fi

title 'doc: docker run'
docker run -d -p 8080:80 \
           --network=network1 \
           --name=$nginx_container_name \
           -v /home/$user/deploys/$version/api:/usr/share/nginx/html:ro \
           nginx:latest

title   '清理未使用的docker资源'
docker system prune -a -f

title '全部执行完毕'
