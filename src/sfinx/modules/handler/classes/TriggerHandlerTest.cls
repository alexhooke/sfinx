@IsTest
public class TriggerHandlerTest {

	@IsTest
	static void testRouting() {

		TriggerHandler.setMaxRecursion(10);

		Test.startTest();
		TestTriggerHandler1 handler = new TestTriggerHandler1();
		handler.run(System.TriggerOperation.BEFORE_INSERT);
		handler.run(System.TriggerOperation.BEFORE_UPDATE);
		handler.run(System.TriggerOperation.BEFORE_DELETE);
		handler.run(System.TriggerOperation.AFTER_INSERT);
		handler.run(System.TriggerOperation.AFTER_UPDATE);
		handler.run(System.TriggerOperation.AFTER_DELETE);
		handler.run(System.TriggerOperation.AFTER_UNDELETE);
		Test.stopTest();

		Assert.areEqual(true, handler.beforeInsertCalled);
		Assert.areEqual(true, handler.beforeUpdateCalled);
		Assert.areEqual(true, handler.beforeDeleteCalled);
		Assert.areEqual(true, handler.afterInsertCalled);
		Assert.areEqual(true, handler.afterUpdateCalled);
		Assert.areEqual(true, handler.afterDeleteCalled);
		Assert.areEqual(true, handler.afterUndeleteCalled);
	}

	@IsTest
	static void testDeactivateAll() {

		Test.startTest();

		// Disable all hanlders
		TriggerHandler.deactivateAll();

		// First handler
		TestTriggerHandler1 handler1 = new TestTriggerHandler1();
		handler1.run(System.TriggerOperation.BEFORE_INSERT);

		// Second handler
		TestTriggerHandler2 handler2 = new TestTriggerHandler2();
		handler2.run(System.TriggerOperation.AFTER_INSERT);

		Test.stopTest();

		Assert.areEqual(handler1.beforeInsertCalled, false);
		Assert.areEqual(handler1.afterInsertCalled, false);
		Assert.areEqual(handler2.beforeInsertCalled, false);
		Assert.areEqual(handler2.afterInsertCalled, false);
	}

	@IsTest
	static void testActivateAll() {

		Test.startTest();

		// Disable all hanlders
		TriggerHandler.deactivateAll();
		// And then activate all hanlders
		TriggerHandler.activateAll();

		// First handler
		TestTriggerHandler1 handler1 = new TestTriggerHandler1();
		handler1.run(System.TriggerOperation.BEFORE_INSERT);

		// Second handler
		TestTriggerHandler2 handler2 = new TestTriggerHandler2();
		handler2.run(System.TriggerOperation.AFTER_INSERT);

		Test.stopTest();

		Assert.areEqual(handler1.beforeInsertCalled, true);
		Assert.areEqual(handler1.afterInsertCalled, false);
		Assert.areEqual(handler2.beforeInsertCalled, false);
		Assert.areEqual(handler2.afterInsertCalled, true);
	}

	@IsTest
	static void testDeactivateOne() {

		Test.startTest();

		// Disable all hanlders
		TriggerHandler.deactivate('TestTriggerHandler1');

		// First handler
		TestTriggerHandler1 handler1 = new TestTriggerHandler1();
		handler1.run(System.TriggerOperation.BEFORE_INSERT);

		// Second handler
		TestTriggerHandler2 handler2 = new TestTriggerHandler2();
		handler2.run(System.TriggerOperation.BEFORE_INSERT);

		Test.stopTest();

		Assert.areEqual(handler1.beforeInsertCalled, false);
		Assert.areEqual(handler2.beforeInsertCalled, true);
	}

	@IsTest
	static void testActivateOne() {

		Test.startTest();

		// Disable all hanlders
		TriggerHandler.deactivate('TestTriggerHandler1');
		TriggerHandler.activate('TestTriggerHandler1');

		// First handler
		TestTriggerHandler1 handler1 = new TestTriggerHandler1();
		handler1.run(System.TriggerOperation.BEFORE_INSERT);

		// Second handler
		TestTriggerHandler2 handler2 = new TestTriggerHandler2();
		handler2.run(System.TriggerOperation.BEFORE_INSERT);

		Test.stopTest();

		Assert.areEqual(handler1.beforeInsertCalled, true);
		Assert.areEqual(handler2.beforeInsertCalled, true);
	}

	@IsTest
	static void testSetMaxRecursion() {

		// Set a new max recursion limit
		TriggerHandler.setMaxRecursion(5);

		// Verify the max recursion limit is set correctly
		System.assertEquals(5, TriggerHandler.getMaxRecursion());
	}

	public class TestTriggerHandler1 extends TriggerHandler {

		public Boolean beforeInsertCalled = false;
		public Boolean beforeUpdateCalled = false;
		public Boolean beforeDeleteCalled = false;
		public Boolean afterInsertCalled = false;
		public Boolean afterUpdateCalled = false;
		public Boolean afterDeleteCalled = false;
		public Boolean afterUndeleteCalled = false;


		protected override void beforeInsert() {
			super.beforeInsert();
			beforeInsertCalled = true;
		}

		protected override void beforeUpdate() {
			super.beforeUpdate();
			beforeUpdateCalled = true;
		}

		protected override void beforeDelete() {
			super.beforeDelete();
			beforeDeleteCalled = true;
		}

		protected override void afterInsert() {
			super.afterInsert();
			afterInsertCalled = true;
		}

		protected override void afterUpdate() {
			super.afterUpdate();
			afterUpdateCalled = true;
		}

		protected override void afterDelete() {
			super.afterDelete();
			afterDeleteCalled = true;
		}

		protected override void afterUndelete() {
			super.afterUndelete();
			afterUndeleteCalled = true;
		}
	}

	public class TestTriggerHandler2 extends TriggerHandler {

		public Boolean beforeInsertCalled = false;
		public Boolean afterInsertCalled = false;

		protected override void beforeInsert() {
			beforeInsertCalled = true;
		}

		protected override void afterInsert() {
			afterInsertCalled = true;
		}
	}
}
