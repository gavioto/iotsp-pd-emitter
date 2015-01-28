#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define SEND_DATA "This is test message from C lang client"
char *socket_path = "./tmp/example_in_literal.sock";

int main(int argc, char *argv[]) {
	struct sockaddr_un addr;
   	char buf[100];
   	int fd,rc;

	if ( (fd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
	   	perror("socket error");
	   	exit(-1);
   	}

	memset(&addr, 0, sizeof(addr));
   	addr.sun_family = AF_UNIX;
   	strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);

	if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
	   	perror("connect error");
	   	exit(-1);
   	}

	rc = write(fd, SEND_DATA, sizeof(SEND_DATA));
   	close(fd);

	return 0;
}

