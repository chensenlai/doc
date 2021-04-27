var Submit = {
		collectData : function($range, json){
			var serialize = [];
			if(json == null) {
				json = {};
			}
			if ($range) {
				serialize.push($range.find("input[type=hidden]"));
				serialize.push($range.find("input[type=text]"));
				serialize.push($range.find("input[type=tel]"));
				serialize.push($range.find("input[type=number]"));
				serialize.push($range.find("input[type=email]"));
				serialize.push($range.find("input[type=password]"));
				serialize.push($range.find("input[type=radio]:checked"));
				serialize.push($range.find("input[type=checkbox]:checked"));
				serialize.push($range.find("select"));
				serialize.push($range.find("textarea"));
			} else {
				serialize.push($("input[type=hidden]"));
				serialize.push($("input[type=text]"));
				serialize.push($("input[type=tel]"));
				serialize.push($("input[type=number]"));
				serialize.push($("input[type=email]"));
				serialize.push($("input[type=password]"));
				serialize.push($("input[type=radio]:checked"));
				serialize.push($("input[type=checkbox]:checked"));
				serialize.push($("select"));
				serialize.push($("textarea"));
			}
			
			// 转化表单数据
			for (var i = 0; i < serialize.length; i++) {
				serialize[i].each(function() {
					var name = $(this).attr("name");
					var value = $(this).val();
					if($.trim(name)){
						var oldValue = json[name];
						if(oldValue) {
							json[name]=oldValue+","+$.trim(value);
						} else {
							json[name]=$.trim(value);
						}
		    		}
				});
			}
			return json;
		},
		
		paramSubmit : function(url, callback, dataType, data, type, async) {
			var returnData = null;
			var param = {};
			param.url = url;
			param.type = type ? type : "post";
			param.dataType = dataType ? dataType : "json";
			param.data = $.param(data);	// key=value&key=value
			param.async = async==false ? false : true;
			
			param.error = function(xhr, str, err) {
				console.log("请求出错，状态码："+str+", 错误信息："+err);
			}
			param.success = function(data) {
				returnData = data;
				if (callback) {
					callback(data);
				}
			}
			$.ajax(param);
			return returnData;
		}
};