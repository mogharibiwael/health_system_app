
getHeader(token) {
 return  {
    "Accept": "application/json",
    "Content-Type": "application/json",
    if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
  };
}