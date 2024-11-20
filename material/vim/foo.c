#include <stdio.h>
#include <stdlib.h>

typedef struct s_node {
    int val;
    struct s_node* left;
    struct s_node* right;
} t_node;

t_node* new_node(int val) {
    t_node* root = malloc(sizeof(t_node));
    root->left = NULL;
    root->right = NULL;
    root->val = val;
    return root;
}

void insert(t_node* root, int val) {
    t_node* new = new_node(val);
    t_node* curr = root;
    t_node* prev;

    while(curr) {
        prev = curr;
        if (val < curr->val)
            curr = curr->left;
        else
            curr = curr->right;
    }
    if (val < prev->val)
        prev->left = new;
    else
        prev->right = new;
}

void print_in_order(t_node* root) {
    if (root == NULL)
        return;
    print_in_order(root->left);
    printf("%d\n", root->val);
    print_in_order(root->right);
}

void print_pre_order(t_node* root) {
    if (root == NULL)
        return;
    printf("%d\n", root->val);
    print_pre_order(root->left);
    print_pre_order(root->right);
}

void print_post_order(t_node* root) {
    if (root == NULL)
        return;
    print_post_order(root->left);
    print_post_order(root->right);
    printf("%d\n", root->val);
}

void free_tree(t_node* root) {
    if (root == NULL)
        return;
    free_tree(root->left);
    free_tree(root->right);
    free(root);
}

int main() {
    /* Delete this text */
    t_node* tree = new_node(5);
    insert(tree, 3);
    insert(tree, 5);
    insert(tree, 4);
    insert(tree, 8);
    insert(tree, 3);
    insert(tree, 2);
    insert(tree, 6);
    insert(tree, 10);

    puts("Pre order: ");
    print_pre_order(tree);
    puts("In order: ");
    print_in_order(tree);
    puts("Post order: ");
    print_post_order(tree);

    puts("Good by!");

    free(tree);
}

