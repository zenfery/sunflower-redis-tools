mydir=$(cd "$(dirname "$0")"; pwd)
myname=$(basename $0)
project_dir=$mydir

source $project_dir/conf/sys.conf

project_name=$PROJECT_NAME
project_version=$VERSION

cd $project_dir
# 打包
mkdir -p $project_dir/build $project_dir/build/${project_name}-${project_version}
cp -rf  bin conf tpl $project_dir/build/${project_name}-${project_version}/
cd build
tar -cvf $project_dir/build/${project_name}-${project_version}.tar ${project_name}-${project_version}/