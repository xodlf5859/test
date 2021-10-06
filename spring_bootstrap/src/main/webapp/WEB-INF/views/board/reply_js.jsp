<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.7/handlebars.min.js"></script>
<script type="text/x-handlebars-template"  id="reply-list-template" >
{{#each .}}
<div class="replyLi" >
   <div class="user-block">
      <img src="<%=request.getContextPath()%>/member/getPictureById/{{replyer}}" class="img-circle img-bordered-sm"/>
    </div>
   
    <div class="timeline-item" >
        <span class="time">
          <i class="fa fa-clock"></i>{{prettifyDate regdate}}
          <a class="btn btn-primary btn-xs {{rno}}-a" id="modifyReplyBtn" data-rno={{rno}}
            onclick="replyModifyModal_go('{{rno}}');"            
            style="display:{{VisibleByLoginCheck replyer}};"
             data-replyer={{replyer}} data-toggle="modal" data-target="#modifyModal">Modify</a>
        </span>
   
        <h3 class="timeline-header"><strong style="display:none;">{{rno}}</strong>{{replyer}}</h3>
        <div class="timeline-body" id="{{rno}}-replytext">{{replytext}} </div>
   </div>
</div>
{{/each}}
</script>
<script type="text/x-handlebars-template"  id="reply-pagination-template" >
<li class="paginate_button page-item">
   <a href="1" aria-controls="example2" data-dt-idx="1" tabindex="0" class="page-link">
      <i class='fas fa-angle-double-left'></i>
   </a>
</li>
<li class="paginate_button page-item">
   <a href="{{#if prev}}{{prevPageNum}}{{/if}}" aria-controls="example2" data-dt-idx="1" tabindex="0" class="page-link">
      <i class='fas fa-angle-left'></i>
   </a>
</li>
{{#each pageNum}}
<li class="paginate_button page-item {{signActive this}} ">
   <a href="{{this}}" aria-controls="example2" data-dt-idx="1" tabindex="0" class="page-link">
      {{this}}
   </a>
</li>
{{/each}}

<li class="paginate_button page-item ">
   <a href="{{#if next}}{{nextPageNum}}{{/if}}" aria-controls="example2" data-dt-idx="1" tabindex="0" class="page-link">
      <i class='fas fa-angle-right'></i>
   </a>
</li>
<li class="paginate_button page-item">
   <a href="{{realEndPage}}" aria-controls="example2" data-dt-idx="1" tabindex="0" class="page-link">
      <i class='fas fa-angle-double-right'></i>
   </a>
</li>   
</script>


<script>
var replyPage=1;
function printData(replyArr,target,templateObject){
   var template=Handlebars.compile(templateObject.html());
   var html = template(replyArr);   
   $('.replyLi').remove();
   target.after(html);
}
function getPage(pageInfo){    
   
   $.ajax({
      url : pageInfo,
      type : "get",
      contentType : "application/json",
      success : function(data){
         printData(data.replyList,$('#repliesDiv'),$('#reply-list-template'));
         printPagination(data.pageMaker,$('ul#pagination'),$('#reply-pagination-template'));
      },
      error:function(error){
         AjaxErrorSecurityRedirectHandler(error.status);
      }
   });
}
Handlebars.registerHelper({
   "prettifyDate":function(timeValue){ //Handlbars에 날짜출력함수 등록
      var dateObj=new Date(timeValue);
      var year=dateObj.getFullYear();
      var month=dateObj.getMonth()+1;
      var date=dateObj.getDate();
      return year+"/"+month+"/"+date;
   },
   "VisibleByLoginCheck":function(replyer){
      var result="none";      
      if(replyer == "${loginUser.id}") result="visible";      
      return result;                    
   },
   "signActive":function(pageNum){
      if(pageNum == replyPage) return 'active';
   }
});
function printPagination(pageMaker,target,templateObject){
   
   var pageNum = new Array(pageMaker.endPage-pageMaker.startPage+1);
   
   for(var i=0;i<pageMaker.endPage-pageMaker.startPage+1;i++){
      pageNum[i]=pageMaker.startPage+i;
   }   
   pageMaker.pageNum=pageNum;  
   pageMaker.prevPageNum=pageMaker.startPage-1;
   pageMaker.nextPageNum=pageMaker.endPage+1;
   
   var template=Handlebars.compile(templateObject.html());   
   var html = template(pageMaker);   
   target.html("").html(html);
}
function replyRegist_go(){
   //alert("click add btn");
   
   var replyer=$('#newReplyWriter').val();
   var replytext=$('#newReplyText').val();
   var bno=$('input[name="bno"]').val()
   
   if(!replytext){
      alert("내용은 필수입니다.");
      return;
   }
   
   //alert(replyer+":"+replytext+":"+bno);
   var data={
         "bno":""+bno+"",
         "replyer":replyer,
         "replytext":replytext   
   }
   $.ajax({
      url:"<%=request.getContextPath()%>/replies",
      type:"post",
      data:JSON.stringify(data),   
      contentType:'application/json',
      success:function(page){
         alert('댓글이 등록되었습니다.\n마지막 페이지로 이동합니다.');
         getPage("<%=request.getContextPath()%>/replies/"+bno+"/"+page); //리스트 출력
         replyPage=page;
         $('#newReplyText').val("");         
      },
      error:function(error){
         AjaxErrorSecurityRedirectHandler(error.status);
      }
   });
      
   
   
}
//댓글 수정
function replyModifyModal_go(rno){
   //alert(rno);
   //var replytext = $('div#'+rno+'-replytext').text()
   //var replyer = $('a.'+rno+'-a').attr('data-replyer');
   
   //alert("rno:"+rno+"\nreplyer:"+replyer+"\nreplytext:"+replytext);
   
   $('div#modifyModal div.modal-body #replytext').val($('div#'+rno+'-replytext').text());
   $('div#modifyModal div.modal-header h4.modal-title').text(rno);
}
function replyModify_go(){
   //alert('reply modify modal btn');
   
   var rno=$('.modal-title').text();
   var replytext=$('#replytext').val();
   
   var sendData={
         rno:rno,
         replytext:replytext
   }
   
   $.ajax({
      url:"<%=request.getContextPath()%>/replies/"+rno,
      type:"put",
      headers:{
         "X-HTTP-Method-Override" : "PUT"
      },
      data:JSON.stringify(sendData),
      contentType:"application/json",
      success:function(result){
         alert("수정되었습니다.");         
         getPage("<%=request.getContextPath()%>/replies/${board.bno}/"+replyPage);
      },
      error:function(error){
         AjaxErrorSecurityRedirectHandler(error.status);      
      },
      complete:function(){
         $('#modifyModal').modal('hide');
      }
   });
}
function replyRemove_go(){
   //alert("click remove btn");
   
   var rno=$('.modal-title').text();
   //alert(rno);
   
   $.ajax({
      url:"<%=request.getContextPath()%>/replies/${board.bno}/"+rno+"/"+replyPage,
      type:"delete",
      headers:{
         "X-HTTP-Method-Override" : "DELETE"
      },
         
      success:function(page){
         alert("삭제되었습니다.");
         getPage("<%=request.getContextPath()%>/replies/${board.bno}/"+page);
         replyPage=page;
      },
      error:function(error){
         AjaxErrorSecurityRedirectHandler(error.status);         
      },
      complete:function(){
         $('#modifyModal').modal('hide');
      }
   });
}
/* page upload */
window.onload=function(){
   getPage("<%=request.getContextPath()%>/replies/${board.bno}/"+replyPage);
   
   $('ul.pagination').on('click','li a',function(event){
      //alert("click page number");
      // $(this) : event.currentTarget
      if($(this).attr("href")) {
         replyPage=$(this).attr("href");
         getPage("<%=request.getContextPath()%>/replies/${board.bno}/"+replyPage);
      }
      return false;
   });
}
</script>