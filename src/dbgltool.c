#include "stdio.h"
#include "string.h"
#include "stdlib.h"

#include "crc.h"
#include "usage.h"

// based on bfd_fill_in_gnu_debuglink_section in binutils
void print_crc32(char* fpath){
  unsigned char buffer[8*1024];
  size_t count;
  FILE* handle = fopen(fpath, "r");
  if(!handle) { perror(fpath); exit(1); };

  union {
    char bytes[4]; // TODO byte order?
    unsigned long crc;
    } crc32;

  while((count = fread(buffer, 1, sizeof buffer, handle)) > 0) {
    crc32.crc = bfd_calc_gnu_debuglink_crc32(crc32.crc, buffer, count);
  }
  fclose(handle);

  fwrite(crc32.bytes, 4, 1, stdout);
  exit(0);
}

void print_section_data(char* str, char crc32[4]) {
  size_t namelen = strlen(str);
  size_t size = ((namelen + 1 + 3) & (~3)) + 4;

  char* buffer = calloc(size, 1);
  if (!buffer) { perror("calloc() failed"); exit(1); };
  memcpy(buffer, str, namelen+1);
  memcpy(&(buffer[size-4]), crc32, 4);

  fwrite(buffer, size, 1, stdout);
  exit(0);
}

int main(int argc, char** argv){
  if (argc <= 2) {
    printf(usage, argv[0]);
    return 1;
  }

  if (strlen(argv[1]) > 1){
    fprintf(stderr, "only `c` and `d` modes exist, please check your parameters.\n");
    return 1;
  }

  switch(argv[1][0]) {
    // calculate and print crc
    case 'c':
      print_crc32(argv[2]);
      break;
    // print .gnu_debuglink content
    //TODO can probably actually just have bash handle this and reduce this tool to a CRC tool?
    case 'd': {
      FILE* handle = fopen(argv[3], "r");
      if(!handle) { perror(argv[3]); return 1; };

      char crc32[4];
      size_t count = fread(crc32, 1, 4, handle);
      if (count != 4){ perror("wat"); fprintf(stderr, "fread() failed to read the correct number of bytes.\n"); return 1; }
      print_section_data(argv[2], crc32);
      };
      break;
    default: {
      fprintf(stderr, "only `c` and `d` modes exist, please check your parameters.\n");
      exit(1);
      }
  }
}

