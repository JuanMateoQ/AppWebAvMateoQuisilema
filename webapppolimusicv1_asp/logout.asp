<%@ Language="VBScript" CodePage="65001" %>
<%
'==========================================================
' Logout: destruye la sesion y regresa al login
'==========================================================
Session.Contents.RemoveAll
Session.Abandon
Response.Redirect "login.asp?bye=1"
%>
