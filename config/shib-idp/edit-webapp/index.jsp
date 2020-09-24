<%@ page pageEncoding="UTF-8" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title><spring:message code="root.title" text="Shibboleth IdP" /></title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath()%>/css/main.css">
  </head>

  <body>
    <div class="wrapper">
      <div class="container">
        <header>
          <img src="<%= request.getContextPath() %><spring:message code="idp.logo" />" alt="<spring:message code="idp.logo.alt-text" text="logo" />">
        </header>
    
        <div class="content">
          <h2><spring:message code="root.message" text="No services are available at this location." /></h2>
        </div>
        <div class="content">
          Having trouble logging in at idp.ncsa.illinois.edu? It may be
          a temporary issue. You can try restarting your web browser to see
          if that fixes the issue. If you continue to experience problems,
          please contact 
          <a
          style="text-decoration:underline; text-decoration-style:dotted;"
          href="mailto:help+idp@ncsa.illinois.edu">help+idp@ncsa.illinois.edu</a>.
        </div>
        <div class="content">
          Having trouble with Duo at NCSA?
          <br/>
          Please visit <a target="_blank"
          style="text-decoration:underline; text-decoration-style:dotted;"
          href="https://go.ncsa.illinois.edu/2fa">https://go.ncsa.illinois.edu/2fa</a>
          for instructions.
        </div>
        <div class="content">
          Forgot your NCSA username?
          <br/>
          Please visit <a target="_blank"
          style="text-decoration:underline; text-decoration-style:dotted;"
          href="https://identity.ncsa.illinois.edu/recover">https://identity.ncsa.illinois.edu/recover</a>
          to recover it.
        </div>
        <div class="content">
          Forgot your NCSA password?
          <br/>
          Please visit <a target="_blank"
          style="text-decoration:underline; text-decoration-style:dotted;"
          href="https://identity.ncsa.illinois.edu/reset">https://identity.ncsa.illinois.edu/reset</a>
          to reset it.
        </div>
        <div class="content">
          Having trouble accessing portal.geni.net?
          <br/>
          Please contact <a
          style="text-decoration:underline; text-decoration-style:dotted;"
          href="mailto:help@geni.net">help@geni.net</a>.
        </div>
      </div>

      <footer>
        <div class="container container-footer">
          <p class="footer-text"><spring:message code="root.footer" text="Insert your footer text here." /></p>
        </div>
      </footer>
    </div>

  </body>
</html>
