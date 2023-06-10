<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bs_pagination/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.min.js"></script>

<script type="text/javascript">


	$(function(){

		// 日历插件
		$(".dateTime").datetimepicker({
			language:"zh-CN",
			format:"yyyy-mm-dd",
			minView:"month",
			initialDate:new Date(),
			autoclose:true,
			todayBtn:true,
			clearBtn:true
		});

		// 初始化市场活动列表
		queryActivityListByCondition(1,10);

		// 查找功能
		$("#queryBtn").click(function (){
			queryActivityListByCondition(1,$("#pagination").bs_pagination("getOption","rowsPerPage"))
		});

		// 打开创建市场活动模态窗口
		$("#createActivityBtn").click(function (){
			$("#createActivityModal").modal("show");
			$.ajax({
				type:"get",
				dataType:"json",
				url:"workbench/activity/queryOwner.do",
				success:function (data){
					var html = "";
					$.each(data.retData,function (i,n){
						html += "<option value='"+n.id+"'>"+n.name+"</option>"
					})
					$("#create-marketActivityOwner").html(html);
					$("#create-marketActivityOwner").val("${sessionScope.sessionUser.id}");
				}
			})
		})

        // 名称为空时提示
        $("#create-marketActivityName").blur(function (){
            if($("#create-marketActivityName").val()==""){
                $("#create-marketActivityNameSpan").html("名称不能为空！")
            } else {
                $("#create-marketActivityNameSpan").html("")
            }
        })

        // 开始日期大于结束日期时提示
        $("#create-startTime").change(function (){
            if ($("#create-startTime").val()!="" && $("#create-endTime").val()!=""){
                if ($("#create-startTime").val()>$("#create-endTime").val()){
                    $("#create-startTimeSpan").html("开始日期不能大于结束日期！")
                } else {
                    $("#create-startTimeSpan").html("")
                    $("#create-endTimeSpan").html("")
                }
            }
        })

        // 结束日期小于开始日期时提示
        $("#create-endTime").change(function (){
            if ($("#create-startTime").val()!="" && $("#create-endTime").val()!=""){
                if ($("#create-startTime").val()>$("#create-endTime").val()){
                    $("#create-endTimeSpan").html("结束日期不能小于开始日期！")
                } else {
                    $("#create-endTimeSpan").html("")
                    $("#create-startTimeSpan").html("")
                }
            }
        })

        // 成本不是非负整数时提示
        $("#create-cost").blur(function (){
            let exp = /^([1-9][0-9]*|0)$/;
            if(!exp.test($("#create-cost").val())){
                $("#create-costSpan").html("成本只能为非负整数！")
            } else {
                $("#create-costSpan").html("")
            }
        })

        // 保存市场活动
        $("#saveActivityBtn").click(function (){
            // 提交前判断是否符合要求
            if ($("#create-marketActivityName").val()==""){
                alert("名称不能为空！");
                return;
            }
            if ($("#create-startTime").val()!="" && $("#create-endTime").val()!=""){
                if ($("#create-startTime").val()>$("#create-endTime").val()){
                    alert("结束日期不能小于开始日期!")
                    return;
                }
            }
            let exp = /^([1-9][0-9]*|0)$/;
            if(!exp.test($("#create-cost").val())){
                alert("成本只能为非负整数！")
                return;
            }

            // 获取键值
            var owner = $("#create-marketActivityOwner").val();
            var name = $.trim($("#create-marketActivityName").val());
            var startDate = $.trim($("#create-startTime").val());
            var endDate = $.trim($("#create-endTime").val());
            var cost = $.trim($("#create-cost").val());
            var description = $.trim($("#create-describe").val());
            // 发异步请求保存并刷新列表
            $.ajax({
                type:"post",
                dataType:"json",
                url:"workbench/activity/saveActivity.do",
                data:{
                    "owner":owner,
                    "name":name,
                    "startDate":startDate,
                    "endDate":endDate,
                    "cost":cost,
                    "description":description
                },
                success:function (data){
                    if (data.code == 1){
                        queryActivityListByCondition(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
                        $("#createActivityForm")[0].reset();
                        $("#createActivityModal").modal("hide");
                    } else {
                        alert(data.message);
                    }
                }
            })
        })

		// 全选
		$("#selectAll").click(function (){
			$("#activityTbody input[type='checkbox']").prop("checked",this.checked)
		})
		// 单选
		$("#activityTbody").on("click",function (){
			$("#selectAll").prop("checked",$("#activityTbody input[type='checkbox']:checked").length == $("#activityTbody input[type='checkbox']").length)
		})

        // 弹出修改市场活动模态窗口
        $("#openEditActivityBtn").click(function (){
            var checkedIds = $("#activityTbody input[type='checkbox']:checked");
            // 验证是否只选择一项
            if (checkedIds.length == 0 || checkedIds.length > 1){
                alert("请选择一项要修改的市场活动！");
                return;
            }
            // 验证通过则通过id异步获取数据填充模态窗口
            if (checkedIds.length == 1){
                var id = checkedIds.val();
                $.ajax({
                    type:"get",
                    dataType:"json",
                    url:"workbench/activity/getEditActivityDetails.do",
                    data:{
                        "id":id
                    },
                    success:function (data){
                        var html = "";
                        $.each(data.retData.ownerList,function (i,n){
                            html += "<option value='"+n.id+"'>"+n.name+"</option>"
                        })
                        $("#edit-marketActivityOwner").html(html);
                        $("#edit-marketActivityId").val(id);
                        $("#edit-marketActivityOwner").val(data.retData.activity.owner);
                        $("#edit-marketActivityName").val(data.retData.activity.name);
                        $("#edit-startTime").val(data.retData.activity.startDate);
                        $("#edit-endTime").val(data.retData.activity.endDate);
                        $("#edit-cost").val(data.retData.activity.cost);
                        $("#edit-describe").val(data.retData.activity.description);

                        $("#editActivityModal").modal("show");
                    }
                })
            }
        })

		// 提交修改市场活动并保存修改
		$("#saveEditActivityBtn").click(function (){
			var id = $("#edit-marketActivityId").val();
			var owner = $.trim($("#edit-marketActivityOwner").val());
			var name = $.trim($("#edit-marketActivityName").val());
			var startDate = $.trim($("#edit-startTime").val());
			var endDate = $.trim($("#edit-endTime").val());
			var cost = $.trim($("#edit-cost").val());
			var description = $.trim($("#edit-describe").val());
			$.ajax({
				type:"post",
				dataType:"json",
				url:"workbench/activity/saveEditActivity.do",
				data:{
					"id":id,
					"owner":owner,
					"name":name,
					"startDate":startDate,
					"endDate":endDate,
					"cost":cost,
					"description":description
				},
				success:function (data){
					if (data.code == 1){
						$("#editActivityModal").modal("hide");
						queryActivityListByCondition($("#pagination").bs_pagination("getOption","currentPage"),$("#pagination").bs_pagination("getOption","rowsPerPage"));
						$("#selectAll").prop("checked",false);
					} else {
						alert(data.message);
					}
				}
			})
		})

		// 删除市场活动
		$("#deleteActivityBtn").click(function (){
			var checkedIds = $("#activityTbody input[type='checkbox']:checked");
			// 验证是否有选择一项
			if (checkedIds.length == 0){
				alert("请至少选择一项市场活动！")
				return;
			}
			// 拼接需要删除的id字符串
			var ids = "";
			$.each(checkedIds,function (i,n){
				ids += "id=" + n.value + "&";
			})
			ids = ids.substr(0,ids.length-1);
			// 向后台发起请求
			if (window.confirm("确认删除这"+checkedIds.length+"项吗？")){
				$.ajax({
					type:"post",
					dataType:"json",
					url:"workbench/activity/deleteActivity.do",
					data:ids,
					success:function (data){
						if (data.code == 1){
							queryActivityListByCondition(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
							$("#selectAll").prop("checked",false);
							alert(data.message);
						}
						if (data.code == 0){
							alert(data.message);
						}
					}
				})
			}
		})

		// 批量导出
		$("#exportActivityAllBtn").click(function (){
			window.location.href = "workbench/activity/exportAllActivity.do";
		})

		// 导入市场活动
		$("#importActivityBtn").click(function (){
			// 验证后缀名
			var fileName = $("#activityFile").val();
			var suffix = fileName.substring(fileName.lastIndexOf(".")+1,fileName.length).toLowerCase();
			if ("xls" != suffix){
				alert("只支持.xls格式文件");
				return;
			}
			// 验证文件大小
			var activityFile = $("#activityFile")[0].files[0];
			if (activityFile.size > 1024*1024*5){
				alert("文件大小不能超过5MB！");
				return;
			}
			// 上传文件
			var formData = new FormData();
			formData.append("activityFile",activityFile);
			$.ajax({
				type:"post",
				data:formData,
				url:"workbench/activity/importActivity.do",
				processData:false,
				contentType:false,
				dataType:"json",
				success:function (data){
					if (data.code == 1){
						alert(data.message)
						$("#importActivityModal").modal("hide");
						queryActivityListByCondition(1,$("#pagination").bs_pagination("getOption","rowsPerPage"));
					} else {
						alert(data.message);
					}
				}
			})
		})
	});
	function queryActivityListByCondition(pageNo,pageSize){
		var name = $.trim($("#queryName").val());
		var owner = $.trim($("#queryOwner").val());
		var startDate = $.trim($("#queryStartTime").val());
		var endDate = $.trim($("#queryEndTime").val());

		$.ajax({
			type:"get",
			dataType:"json",
			url:"workbench/activity/queryActivityListByCondition.do",
			data:{
				"name":name,
				"owner":owner,
				"startDate":startDate,
				"endDate":endDate,
				"pageNo":pageNo,
				"pageSize":pageSize
			},
			success:function (data){
				if (data.code == 1){
					var totalPages = (data.retData.totals % pageSize == 0) ? (data.retData.totals/pageSize) : (Math.ceil(data.retData.totals/pageSize)) ;
					var html = "";
					$.each(data.retData.activityList,function (i,n){
						html += "<tr class=\"active\"> " +
								"<td><input type=\"checkbox\" value=\'"+n.id+"\'/></td> " +
								"<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='detail.html';\">"+n.name+"</a></td> " +
								"<td>"+n.owner+"</td> " +
								"<td>"+n.startDate+"</td> " +
								"<td>"+n.endDate+"</td> " +
								"</tr>"
					})
					$("#activityTbody").html(html);
					$("#pagination").bs_pagination({
						currentPage:pageNo,
						rowsPerPage:pageSize,
						totalPages:totalPages,
						totalRows:data.retData.totals,
						visiblePageLinks:5,
						showRowsInfo:true,
						showRowsPerPage:true,
						showGoToPage:true,
						onChangePage:function (event,pageObj){
							$("#selectAll").prop("checked",false);
							queryActivityListByCondition(pageObj.currentPage,pageObj.rowsPerPage);
						}
					})
				} else {
					alert(data.message);
/*					$("#queryName").val("");
					$("#queryOwner").val("");
					$("#queryStartTime").val("");
					$("#queryEndTime").val("");*/
				}
			}
		})
	}
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="createActivityForm">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
<%--								  <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName"><span id="create-marketActivityNameSpan" style="color: #ff0a05"></span>
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control dateTime" id="create-startTime"><span id="create-startTimeSpan" style="color: #ff0a05"></span>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control dateTime" id="create-endTime"><span id="create-endTimeSpan" style="color: #ff0a05"></span>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost"><span id="create-costSpan" style="color: #ff0a05"></span>
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<input type="hidden" id="edit-marketActivityId">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
<%--								  <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control dateTime" id="edit-startTime">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control dateTime" id="edit-endTime">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditActivityBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="queryName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="queryOwner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control dateTime" type="text" id="queryStartTime" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control dateTime" type="text" id="queryEndTime">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="openEditActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="selectAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityTbody">
<%--						<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>

			<div id="pagination"></div>
			
			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>