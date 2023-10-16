function createList(arr) {
  class ListNode {
    constructor(val, next) {
      this.val = (val === undefined ? 0 : val)
      this.next = (next === undefined ? null : next)
    }
  }

  let head = new ListNode(arr[0]);
  let start = head;
  for (let i = 1; i < arr.length; i++) {
    start.next = new ListNode(arr[i]);
    start = start.next;
  }

  return head;
}

function test(arr) {
  let list = insertionSortList(createList(arr));
  const arr = [];
  while (list) {
    arr.push(list.val);
    list = list.next;
  }

  return list;
}


function insertionSortList(head) {
  let initialHead = head;

  

}

console.log(format([4,2,1,3]));
console.log(format([-1,5,3,4,0]));