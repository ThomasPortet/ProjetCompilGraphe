typedef struct _node_t {
	int label;
	char *carac;
	struct _node_t *child;
	struct _node_t *right;
} node_t;

int nextlabel();

node_t* makenode(char* carac);
void freenode(node_t* node);
